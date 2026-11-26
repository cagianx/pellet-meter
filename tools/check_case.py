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

Uso:  tools/check_case.py [enclosure/case.scad]
"""

import re
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

TOLLERANZA = 0.05  # mm: il render e' esatto, questo copre solo i float


def openscad(scad: Path, pezzo: str, extra: list[str]) -> tuple[dict, tuple]:
    """Renderizza un pezzo e ritorna (quote dichiarate, bounding box)."""
    with tempfile.NamedTemporaryFile(suffix=".stl") as tmp:
        cmd = ["openscad", "-o", tmp.name, "-D", f'pezzo="{pezzo}"',
               *extra, str(scad)]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            raise SystemExit(f"openscad fallito per {pezzo}:\n{res.stderr}")

        quote = {}
        for m in re.finditer(r'ECHO: "QUOTE (\w+)=([^"]+)"', res.stderr):
            quote[m.group(1)] = [float(v) for v in re.split(r"[x,]", m.group(2))]

        return quote, bbox(Path(tmp.name).read_bytes())


def bbox(dati: bytes) -> tuple:
    """Bounding box di un STL, ASCII o binario."""
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

    assi = list(zip(*punti))
    return tuple(max(a) - min(a) for a in assi)


def vicino(a: float, b: float) -> bool:
    return abs(a - b) <= TOLLERANZA


def main() -> int:
    scad = Path(sys.argv[1] if len(sys.argv) > 1 else "enclosure/case.scad")
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
    quote, box = openscad(scad, "scatola", [])
    esterno = quote["esterno"]
    # La scatola e' alta quanto l'esterno meno il coperchio, che si appoggia
    # in cima alle pareti invece di sommarsi.
    coperchio_sp = leggi_parametro(scad, "coperchio_sp")
    labbro = leggi_parametro(scad, "labbro")
    controlla("scatola", (esterno[0], esterno[1], esterno[2] - coperchio_sp), box)

    _, box_cop = openscad(scad, "coperchio", [])
    controlla("coperchio", (esterno[0], esterno[1], coperchio_sp + labbro),
              box_cop)

    # --- La finestra ottica cade dentro il fondo? --------------------------

    print("finestra ottica")
    ottica = quote["ottica"]
    dentro = 0 < ottica[0] < esterno[0] and 0 < ottica[1] < esterno[1]
    print(f"  {'ok  ' if dentro else 'NO  '}centro a "
          f"({ottica[0]:.1f}, {ottica[1]:.1f}) dentro {esterno[0]:.1f} x "
          f"{esterno[1]:.1f}")
    if not dentro:
        errori.append("finestra ottica fuori dal fondo")

    # --- Il modello segue i parametri? -------------------------------------
    #
    # Una batteria piu' spessa deve far crescere l'altezza, una piu' lunga
    # la lunghezza. Se il solido non cambia, da qualche parte c'e' un
    # numero scritto a mano al posto del parametro.

    print("il solido segue i parametri")
    _, box2 = openscad(scad, "scatola", ["-D", "batteria=[60,30,9]"])

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


def leggi_parametro(scad: Path, nome: str) -> float:
    """Legge un parametro scalare dal sorgente."""
    m = re.search(rf"^{nome}\s*=\s*([\d.]+)\s*;", scad.read_text(), re.M)
    if not m:
        raise SystemExit(f"parametro {nome} non trovato in {scad}")
    return float(m.group(1))


if __name__ == "__main__":
    sys.exit(main())
