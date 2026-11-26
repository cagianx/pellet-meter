#!/usr/bin/env python3
"""Verifica che la scheda, con i suoi componenti, entri nel contenitore.

Due controlli, perche' rispondono a domande diverse:

  ingombro      la scheda sta dentro la cavita' interna? Confronto asse per
                asse, che dice di quanto eccede e in quale direzione.
  collisione    con il foro ottico della scheda allineato a quello del
                contenitore, la scheda tocca pareti, divisorio o coperchio?
                Risposta geometrica: si interseca il solido della scheda con
                quello del contenitore (enclosure/viste/accoppiamento.scad).

Nessuna quota e' scritta qui dentro. Quelle del contenitore si leggono dai
suoi `echo("QUOTE ...")`, quelle della scheda dal .kicad_pcb e dallo STL
esportato da kicad-cli. Un parametro che cambia da una parte o dall'altra
si propaga da solo, ed e' il motivo per cui questo controllo ha senso
rieseguirlo invece di fidarsi di un numero scritto una volta.

Uso:
    tools/check_fit.py
    tools/check_fit.py --scheda-finta 80x60x20   # il caso che deve fallire

Esce con codice 1 se la scheda non ci sta.
"""
import argparse
import re
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

PCB = Path("kicad/pellet-meter.kicad_pcb")
CASE = Path("enclosure/case.scad")
ACCOPPIAMENTO = Path("enclosure/viste/accoppiamento.scad")

# Fuori da KiCad: il breakout VL53L1X e' montato su un header femmina e il
# modulo XIAO pure. Il corpo del breakout non ha modello 3D (vedi
# docs/hardware/pcb/), quindi lo aggiunge accoppiamento.scad.
SENSORE_ALTEZZA = 8.5


def openscad(args: list[str]) -> subprocess.CompletedProcess:
    res = subprocess.run(["openscad", *args], capture_output=True, text=True)
    if res.returncode != 0:
        raise SystemExit(f"openscad fallito:\n{res.stderr}")
    return res


def quote_contenitore() -> dict:
    """Le quote che case.scad dichiara, non quelle che crediamo abbia."""
    with tempfile.NamedTemporaryFile(suffix=".stl") as tmp:
        res = openscad(["-o", tmp.name, "-D", 'pezzo="scatola"', str(CASE)])
    quote = {}
    for m in re.finditer(r'ECHO: "QUOTE (\w+)=([^"]+)"', res.stderr):
        quote[m.group(1)] = [float(v) for v in re.split(r"[x,]", m.group(2))]
    mancanti = {"esterno", "interno", "ottica"} - set(quote)
    if mancanti:
        raise SystemExit(f"{CASE} non dichiara le quote {sorted(mancanti)}")
    return quote


def parametro(nome: str) -> float:
    m = re.search(rf"^{nome}\s*=\s*([\d.]+)\s*;", CASE.read_text(), re.M)
    if not m:
        raise SystemExit(f"parametro {nome} non trovato in {CASE}")
    return float(m.group(1))


def lista_parametro(nome: str) -> list[float]:
    m = re.search(rf"^{nome}\s*=\s*\[([^\]]+)\]\s*;", CASE.read_text(), re.M)
    if not m:
        raise SystemExit(f"parametro {nome} non trovato in {CASE}")
    return [float(v) for v in m.group(1).split(",")]


def bbox(dati: bytes) -> tuple:
    """(min, max) per asse di un STL, ASCII o binario."""
    # Un'intersezione vuota non produce un file vuoto: OpenSCAD scrive
    # comunque l'intestazione. Senza questo controllo il caso "non si
    # toccano" finisce in errore invece che in un ok.
    if len(dati) < 84:
        return None
    if dati[:5] == b"solid" and b"facet" in dati[:512]:
        punti = [tuple(map(float, m)) for m in
                 re.findall(rb"vertex\s+(\S+)\s+(\S+)\s+(\S+)", dati)]
    else:
        n = struct.unpack("<I", dati[80:84])[0]
        punti = [struct.unpack("<3f", dati[84 + i * 50 + 12 + j * 12:
                                           84 + i * 50 + 24 + j * 12])
                 for i in range(n) for j in range(3)]
    if not punti:
        return None
    assi = list(zip(*punti))
    return [(min(a), max(a)) for a in assi]


def foro_ottico() -> tuple:
    """Centro del foro ottico sul PCB, in coordinate del foglio KiCad."""
    testo = PCB.read_text()
    cerchi = re.findall(
        r"\(gr_circle\s*\(center ([-\d.]+) ([-\d.]+)\)"
        r"\s*\(end ([-\d.]+) ([-\d.]+)\)(?:(?!\(layer).)*?"
        r'\(layer "Edge\.Cuts"\)', testo, re.S)
    if len(cerchi) != 1:
        raise SystemExit(
            f"su Edge.Cuts ci sono {len(cerchi)} cerchi: il foro ottico "
            "deve essere uno solo, altrimenti non si sa su quale allineare")
    cx, cy, ex, _ = (float(v) for v in cerchi[0])
    return cx, cy, abs(ex - cx) * 2


def esporta_scheda(dest: Path, finta: str | None) -> None:
    if finta:
        # La scheda volutamente troppo grande: serve a provare che il
        # controllo sappia dire di no. Senza questa prova, un controllo che
        # non ha mai fallito non ha dimostrato niente.
        x, y, z = (float(v) for v in finta.lower().split("x"))
        cx, cy, _ = foro_ottico()
        sorg = dest.with_suffix(".scad")
        # Stesse coordinate dello STL vero: origine sul foglio KiCad, Y
        # rovesciata, fondo della scheda a z = 0.
        sorg.write_text(
            f"translate([{cx - x / 2}, {-cy - y / 2}, 0]) "
            f"cube([{x}, {y}, {z}]);\n")
        openscad(["-o", str(dest), str(sorg)])
        return
    subprocess.run(
        ["kicad-cli", "pcb", "export", "stl", "--no-dnp", "--force",
         "-o", str(dest), str(PCB)], check=True, capture_output=True)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--scheda-finta", metavar="LxPxA",
                    help="sostituisce la scheda con un parallelepipedo, "
                         "per provare che il controllo sappia fallire")
    args = ap.parse_args()

    if not PCB.exists():
        print(f"{PCB} non esiste: niente da verificare.")
        return 0
    if not CASE.exists():
        print(f"{CASE} non esiste: niente da verificare.")
        return 0

    quote = quote_contenitore()
    interno = quote["interno"]
    ottica = quote["ottica"]
    parete = parametro("parete")
    fondo = parametro("fondo")
    coperchio_sp = parametro("coperchio_sp")
    sensore = lista_parametro("sensore")

    errori = []
    tmp = Path(tempfile.mkdtemp())
    stl = tmp / "scheda.stl"
    esporta_scheda(stl, args.scheda_finta)
    b = bbox(stl.read_bytes())
    if b is None:
        raise SystemExit("lo STL della scheda e' vuoto")
    dim = [hi - lo for lo, hi in b]

    print("scheda contro cavita' interna")
    print(f"  scheda   {dim[0]:6.2f} x {dim[1]:6.2f} x {dim[2]:6.2f} mm"
          f"   (componenti compresi)")
    print(f"  cavita'  {interno[0]:6.2f} x {interno[1]:6.2f} x "
          f"{interno[2]:6.2f} mm")
    for k, (nome, verso) in enumerate(
            [("X", "in larghezza"), ("Y", "in profondita'"),
             ("Z", "in altezza")]):
        ecc = dim[k] - interno[k]
        if ecc > 0.001:
            print(f"  NO   {nome}: eccede di {ecc:.2f} mm {verso}")
            errori.append(f"{nome} eccede di {ecc:.2f} mm {verso}")
        else:
            print(f"  ok   {nome}: avanzano {-ecc:.2f} mm {verso}")

    # --- collisione, con il foro ottico allineato --------------------------
    #
    # Il confronto degli ingombri non vede ne' il divisorio fra i due vani
    # ne' la battuta del coperchio, e nemmeno il fatto che il foro della
    # scheda debba cadere su quello del contenitore. Questo lo vede.
    cx, cy, d = foro_ottico()
    print(f"\nforo ottico: sulla scheda d {d:.1f} mm, "
          f"sul contenitore a ({ottica[0]:.1f}, {ottica[1]:.1f}) interni")

    uscita = tmp / "collisione.stl"
    openscad([
        "-o", str(uscita),
        "-D", f'pcb="{stl}"',
        "-D", f"pcb_foro=[{cx},{cy}]",
        "-D", f"pcb_zmin={b[2][0]}",
        "-D", f"bersaglio=[{parete + ottica[0]},{parete + ottica[1]}]",
        "-D", f"appoggio={fondo}",
        "-D", f"altezza_scatola={quote['esterno'][2] - coperchio_sp}",
        "-D", f"sensore_corpo=[{sensore[0]},{sensore[1]},{sensore[2]}]",
        "-D", f"sensore_altezza={SENSORE_ALTEZZA}",
        str(ACCOPPIAMENTO),
    ])
    scontro = bbox(uscita.read_bytes())
    if scontro is None:
        print("  ok   la scheda non tocca scatola, divisorio ne' coperchio")
    else:
        sdim = [hi - lo for lo, hi in scontro]
        print(f"  NO   la scheda compenetra il contenitore per "
              f"{sdim[0]:.2f} x {sdim[1]:.2f} x {sdim[2]:.2f} mm")
        print(f"       la zona di contatto sta fra "
              f"({scontro[0][0]:.1f}, {scontro[1][0]:.1f}, "
              f"{scontro[2][0]:.1f}) e ({scontro[0][1]:.1f}, "
              f"{scontro[1][1]:.1f}, {scontro[2][1]:.1f})")
        errori.append("la scheda compenetra il contenitore")

    print()
    if errori:
        print("LA SCHEDA NON ENTRA:")
        for e in errori:
            print(f"  - {e}")
        return 1
    print("la scheda entra nel contenitore.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
