#!/usr/bin/env python3
"""Converte un STL ASCII in STL binario.

Serve al visualizzatore del sito. `kicad-cli pcb export stl` scrive solo
ASCII: circa 250 byte per triangolo contro i 50 del binario, cioe' 2,9 MB
invece di 580 kB per questa scheda. Su una pagina web la differenza si
vede, e il visualizzatore (docs/docs/assets/js/stl-viewer.js) legge
comunque solo il binario, perche' il formato ASCII si parsa in JavaScript
molto piu' lentamente di quanto valga.

Uso:  tools/stl_bin.py ingresso.stl uscita.stl
"""
import re
import struct
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2

    dati = open(sys.argv[1], "rb").read()
    if dati[:5] != b"solid" or b"facet" not in dati[:512]:
        print(f"{sys.argv[1]} non e' un STL ASCII: niente da convertire")
        return 1

    # Un triangolo e' una normale piu' tre vertici, sempre in quest'ordine.
    # Si leggono i numeri in blocco invece di seguire la grammatica: il
    # formato non ha altro dentro un blocco facet.
    numeri = re.findall(
        rb"facet\s+normal\s+(\S+)\s+(\S+)\s+(\S+)"
        rb"(?:\s|\S)*?vertex\s+(\S+)\s+(\S+)\s+(\S+)"
        rb"\s+vertex\s+(\S+)\s+(\S+)\s+(\S+)"
        rb"\s+vertex\s+(\S+)\s+(\S+)\s+(\S+)", dati)
    if not numeri:
        print(f"{sys.argv[1]}: nessun triangolo trovato")
        return 1

    with open(sys.argv[2], "wb") as f:
        f.write(b"STL binario da " + sys.argv[1].encode()[:60].ljust(65))
        f.write(struct.pack("<I", len(numeri)))
        for t in numeri:
            f.write(struct.pack("<12fH", *[float(v) for v in t], 0))

    print(f"  {len(numeri)} triangoli convertiti in binario")
    return 0


if __name__ == "__main__":
    sys.exit(main())
