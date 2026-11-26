#!/usr/bin/env python3
"""Controlla che il contenitore generato corrisponda ai parametri dichiarati.

Il render che non fallisce dice solo che il file e' sintatticamente valido.
Non dice se il solido ha davvero le quote che il modello afferma di avere:
basta un parametro usato in un posto e dimenticato in un altro perche' il
pezzo esca diverso da come e' documentato, e il render resta verde.

Qui si confrontano tre cose:
  - le quote che case.scad dichiara con echo()
  - il bounding box del solido davvero prodotto
  - il fatto che cambiando un parametro il solido cambi di conseguenza

Uso:  tools/check_case.py [enclosure/case.scad] [-D parametro=valore ...]

I -D passati qui finiscono in tutti i render, e servono a provare che un
controllo sa anche fallire. Un controllo che nessuno ha mai visto scattare
non e' una verifica, e' una decorazione:

  tools/check_case.py -D peso_stimato=400    # l'incollaggio non regge piu'
"""

import re
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

TOLLERANZA = 0.05  # mm: il render e' esatto, questo copre solo i float


DA_RIGA_DI_COMANDO: list[str] = []  # i -D passati allo script


def openscad(scad: Path, pezzo: str, extra: list[str]) -> tuple[dict, list]:
    """Renderizza un pezzo e ritorna (quote dichiarate, triangoli)."""
    with tempfile.NamedTemporaryFile(suffix=".stl") as tmp:
        cmd = ["openscad", "-o", tmp.name, "-D", f'pezzo="{pezzo}"',
               *DA_RIGA_DI_COMANDO, *extra, str(scad)]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            raise SystemExit(f"openscad fallito per {pezzo}:\n{res.stderr}")

        quote = {}
        for m in re.finditer(r'ECHO: "QUOTE (\w+)=([^"]+)"', res.stderr):
            quote[m.group(1)] = [float(v) for v in re.split(r"[x,]", m.group(2))]

        return quote, triangoli(Path(tmp.name).read_bytes())


def triangoli(dati: bytes) -> list:
    """Facce di un STL, ASCII o binario, come liste di tre vertici.

    Si leggono le facce e non i soli vertici perche' col bounding box non si
    verificano le due cose che contano sul pezzo nuovo: quanto misura la
    faccia di incollaggio, e se il tappo e' attaccato o galleggia.
    """
    if dati[:5] == b"solid" and b"facet" in dati[:512]:
        punti = [tuple(map(float, m)) for m in
                 re.findall(rb"vertex\s+(\S+)\s+(\S+)\s+(\S+)", dati)]
    else:
        n = struct.unpack("<I", dati[80:84])[0]
        punti = []
        for i in range(n):
            base = 84 + i * 50 + 12
            for j in range(3):
                punti.append(struct.unpack("<3f", dati[base + j * 12:
                                                       base + j * 12 + 12]))
    if not punti:
        raise SystemExit("STL vuoto: il render non ha prodotto geometria")

    return [tuple(punti[i:i + 3]) for i in range(0, len(punti), 3)]


def bbox(facce: list) -> tuple:
    assi = list(zip(*[v for t in facce for v in t]))
    return tuple(max(a) - min(a) for a in assi)


def area_triangolo(t) -> float:
    (ax, ay, az), (bx, by, bz), (cx, cy, cz) = t
    u = (bx - ax, by - ay, bz - az)
    v = (cx - ax, cy - ay, cz - az)
    n = (u[1] * v[2] - u[2] * v[1],
         u[2] * v[0] - u[0] * v[2],
         u[0] * v[1] - u[1] * v[0])
    return 0.5 * sum(c * c for c in n) ** 0.5


def area_appoggio(facce: list) -> float:
    """Area delle facce che stanno sul piano piu' basso del solido.

    E' la superficie che tocca il piano di stampa, e nel pezzo montato
    quella che tocca il biadesivo. Misurarla sul solido e' l'unico modo di
    accorgersi che qualcuno ha messo uno zoccolo o un rilievo sul fondo:
    una faccia non piu' piana non e' piu' incollabile, e il bounding box
    resta identico.
    """
    z0 = min(v[2] for t in facce for v in t)
    return sum(area_triangolo(t) for t in facce
               if all(abs(v[2] - z0) < 1e-4 for v in t))


def componenti(facce: list) -> int:
    """Quanti solidi staccati contiene la geometria.

    Il tappo deve risultare legato al corpo dal cordino. Se il cordino non
    arriva a toccare la parete il render esce identico a vedersi, con il
    tappo che galleggia: un pezzo che si stampa in due tronconi e si perde
    al primo smontaggio.
    """
    padre = {}

    def radice(a):
        while padre[a] != a:
            padre[a] = padre[padre[a]]
            a = padre[a]
        return a

    def unisci(a, b):
        ra, rb = radice(a), radice(b)
        if ra != rb:
            padre[ra] = rb

    for t in facce:
        # I vertici si arrotondano al micron: due facce che condividono uno
        # spigolo hanno gli stessi vertici a meno dell'errore del float32
        # dello STL.
        v = [tuple(round(c, 3) for c in p) for p in t]
        for p in v:
            padre.setdefault(p, p)
        unisci(v[0], v[1])
        unisci(v[0], v[2])

    return len({radice(p) for p in padre})


def vicino(a: float, b: float) -> bool:
    return abs(a - b) <= TOLLERANZA


def main() -> int:
    argomenti = sys.argv[1:]
    if argomenti and not argomenti[0].startswith("-"):
        scad = Path(argomenti.pop(0))
    else:
        scad = Path("enclosure/case.scad")
    DA_RIGA_DI_COMANDO[:] = argomenti
    if not scad.exists():
        print(f"{scad} non esiste: niente da controllare.")
        return 0

    errori = []

    def controlla(descrizione, atteso, ottenuto):
        ok = all(vicino(a, o) for a, o in zip(atteso, ottenuto))
        segno = "ok  " if ok else "NO  "
        att = " x ".join(f"{v:.2f}" for v in atteso)
        ott = " x ".join(f"{v:.2f}" for v in ottenuto)
        print(f"  {segno}{descrizione}: atteso {att}, ottenuto {ott}")
        if not ok:
            errori.append(descrizione)

    # --- Le quote dichiarate corrispondono al solido? ----------------------

    print("quote dichiarate contro solido generato")
    quote, facce = openscad(scad, "scatola", [])
    box = bbox(facce)
    esterno = quote["esterno"]
    # La scatola e' alta quanto l'esterno meno il coperchio, che si appoggia
    # in cima alle pareti invece di sommarsi.
    coperchio_sp = leggi_parametro(scad, "coperchio_sp")
    labbro = leggi_parametro(scad, "labbro")
    # In lunghezza la scatola misura piu' dell'ingombro esterno: il tappo
    # della USB-C si stampa parcheggiato di fianco, legato dal cordino.
    sporgenza = quote["tappo_sporgenza"][0]
    controlla("scatola", (esterno[0] + sporgenza, esterno[1],
                          esterno[2] - coperchio_sp), box)

    _, facce_cop = openscad(scad, "coperchio", [])
    controlla("coperchio", (esterno[0], esterno[1], coperchio_sp + labbro),
              bbox(facce_cop))

    # --- La finestra ottica cade dentro il fondo? --------------------------

    print("finestra ottica")
    ottica = quote["ottica"]
    dentro = 0 < ottica[0] < esterno[0] and 0 < ottica[1] < esterno[1]
    print(f"  {'ok  ' if dentro else 'NO  '}centro a "
          f"({ottica[0]:.1f}, {ottica[1]:.1f}) dentro {esterno[0]:.1f} x "
          f"{esterno[1]:.1f}")
    if not dentro:
        errori.append("finestra ottica fuori dal fondo")

    # --- L'incollaggio regge il peso? --------------------------------------
    #
    # Il contenitore si monta capovolto, incollato sotto il coperchio della
    # tramoggia: l'area della faccia incollata e' la cosa che lo tiene su.
    # Il minimo lo calcola il modello dal peso stimato, dalla portata del
    # biadesivo e dal fattore di sicurezza; qui si controlla che l'area
    # dichiarata ci stia sopra, e quanto manca se non ci sta.

    print("incollaggio")
    area = quote["area_incollaggio"][0]
    minima = quote["area_incollaggio_minima"][0]
    basta = area >= minima
    print(f"  {'ok  ' if basta else 'NO  '}area {area:.0f} mm2, "
          f"minimo per il peso {minima:.0f} mm2"
          + ("" if basta else f": mancano {minima - area:.0f} mm2"))
    if not basta:
        errori.append(f"area di incollaggio insufficiente di "
                      f"{minima - area:.0f} mm2")

    # La faccia incollata deve essere piana e continua, non solo abbastanza
    # grande. Sul piano piu' basso del solido ci stanno il fondo e, di
    # fianco, l'impronta di tappo e cordino: il modello dichiara la somma.
    appoggio = quote["area_appoggio"][0]
    misurata = area_appoggio(facce)
    # La tolleranza copre la sfaccettatura: spigoli raccordati e foro
    # ottico sono poligoni inscritti, quindi il solido misura un pelo meno
    # del conto analitico.
    piana = abs(misurata - appoggio) <= 1.0
    print(f"  {'ok  ' if piana else 'NO  '}piano d'appoggio: dichiarato "
          f"{appoggio:.1f} mm2, misurato sul solido {misurata:.1f} mm2")
    if not piana:
        errori.append("il piano d'appoggio non misura quanto dichiarato")

    # --- Il tappo e' attaccato? --------------------------------------------

    print("tappo della USB-C")
    pezzi = componenti(facce)
    print(f"  {'ok  ' if pezzi == 1 else 'NO  '}la scatola e' un solo solido: "
          f"{pezzi} componente(i) connessa(e)")
    if pezzi != 1:
        errori.append(f"la scatola esce in {pezzi} tronconi: il tappo "
                      f"non e' legato al corpo")

    # --- Il coperchio si chiude davvero? -----------------------------------
    #
    # Il dentino sporge dalla battuta e deve finire dentro la finestra del
    # labbro. Se la finestra e' alta dove non serve, i due pezzi si
    # compenetrano: a schermo non si vede — si guarda un pezzo alla volta —
    # e nessuna quota cambia.

    print("chiusura")
    vuoto = intersezione_vuota(scad)
    print(f"  {'ok  ' if vuoto else 'NO  '}scatola e coperchio chiusi non si "
          f"compenetrano")
    if not vuoto:
        errori.append("scatola e coperchio si compenetrano a coperchio "
                      "chiuso: il dentino non entra nella sua finestra")

    # --- Il modello segue i parametri? -------------------------------------
    #
    # Una batteria piu' spessa deve far crescere l'altezza, una piu' lunga
    # la lunghezza. Se il solido non cambia, da qualche parte c'e' un
    # numero scritto a mano al posto del parametro.

    print("il solido segue i parametri")
    _, facce2 = openscad(scad, "scatola", ["-D", "batteria=[60,30,9]"])
    box2 = bbox(facce2)

    # L'altezza segue la batteria uno a uno, perche' la cella e' il
    # componente piu' spesso. La lunghezza no: cresce, ma di meno del
    # parametro, perche' con le quote di partenza a comandare e' il vano
    # elettronica (50,6 mm contro i 48,8 della batteria). Pretendere che
    # cresca "di 12" vorrebbe dire riscrivere qui la logica del modello,
    # cioe' controllarlo con se stesso.
    for nome, ok, prima, dopo in [
        ("altezza con batteria +3 mm", box2[2] > box[2] + 2.9, box[2], box2[2]),
        ("lunghezza con batteria piu' lunga", box2[0] > box[0] + 0.5,
         box[0], box2[0]),
    ]:
        print(f"  {'ok  ' if ok else 'NO  '}{nome}: {prima:.2f} -> {dopo:.2f}")
        if not ok:
            errori.append(nome)

    print()
    if errori:
        print(f"{len(errori)} controllo(i) fallito(i): " + ", ".join(errori))
        return 1
    print("il contenitore corrisponde ai parametri dichiarati.")
    return 0


def intersezione_vuota(scad: Path) -> bool:
    """Vero se scatola e coperchio chiusi non hanno volume in comune.

    Il modello sa emettere la loro intersezione con pezzo="interferenza".
    OpenSCAD, quando il risultato e' vuoto, lo dice e non scrive il file:
    e' il caso buono, e si riconosce dal file che non c'e'.
    """
    with tempfile.TemporaryDirectory() as dir:
        uscita = Path(dir) / "interferenza.stl"
        subprocess.run(["openscad", "-o", str(uscita),
                        "-D", 'pezzo="interferenza"',
                        *DA_RIGA_DI_COMANDO, str(scad)],
                       capture_output=True, text=True)
        return not (uscita.exists() and uscita.stat().st_size > 0)


def leggi_parametro(scad: Path, nome: str) -> float:
    """Legge un parametro scalare dal sorgente."""
    m = re.search(rf"^{nome}\s*=\s*([\d.]+)\s*;", scad.read_text(), re.M)
    if not m:
        raise SystemExit(f"parametro {nome} non trovato in {scad}")
    return float(m.group(1))


if __name__ == "__main__":
    sys.exit(main())
