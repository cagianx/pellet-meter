#!/usr/bin/env python3
"""Stringe il viewBox di un SVG attorno al contenuto.

Il ritaglio non viene indovinato leggendo le coordinate dell'SVG: viene
misurato sui pixel di un PNG renderizzato dallo stesso file, e poi
riportato in millimetri. Contare i pixel accesi e' esatto; interpretare i
comandi di un path significa ricostruire archi, trasformazioni e spessori
di tratto, cioe' sbagliare in silenzio.

Uso:
    crop_svg.py <file.svg> <WxH+X+Y> <png_w> <png_h>

dove WxH+X+Y e' il formato %@ di ImageMagick (il bounding box del
contenuto) e png_w/png_h sono le dimensioni in pixel di quel PNG.
"""

import re
import sys

MARGINE_MM = 4.0


def main() -> int:
    if len(sys.argv) != 5:
        print(__doc__, file=sys.stderr)
        return 2

    percorso, bbox, png_w, png_h = sys.argv[1], sys.argv[2], *sys.argv[3:5]

    m = re.fullmatch(r"(\d+)x(\d+)\+(\d+)\+(\d+)", bbox.strip())
    if not m:
        print(f"bounding box non riconosciuto: {bbox!r}", file=sys.stderr)
        return 1
    bw, bh, bx, by = (int(v) for v in m.groups())

    svg = open(percorso, encoding="utf-8").read()

    # La radice dell'SVG di KiCad: width e height in mm, viewBox in unita'
    # che coincidono con i mm. Se KiCad cambiasse formato questo smette di
    # trovare la riga, e lo diciamo invece di produrre un file sbagliato.
    radice = re.search(
        r'width="([\d.]+)mm"\s+height="([\d.]+)mm"\s+'
        r'viewBox="([\d.\-]+)\s+([\d.\-]+)\s+([\d.]+)\s+([\d.]+)"',
        svg,
    )
    if not radice:
        print("radice SVG non riconosciuta: formato di KiCad cambiato?",
              file=sys.stderr)
        return 1

    vb_x, vb_y, vb_w, vb_h = (float(v) for v in radice.groups()[2:])

    # Da pixel del PNG a unita' del viewBox.
    sx = vb_w / float(png_w)
    sy = vb_h / float(png_h)

    x = vb_x + bx * sx - MARGINE_MM
    y = vb_y + by * sy - MARGINE_MM
    w = bw * sx + 2 * MARGINE_MM
    h = bh * sy + 2 * MARGINE_MM

    # Il margine non puo' spingere la finestra fuori dal foglio.
    x = max(vb_x, x)
    y = max(vb_y, y)
    w = min(w, vb_x + vb_w - x)
    h = min(h, vb_y + vb_h - y)

    nuovo = (
        f'width="{w:.4f}mm" height="{h:.4f}mm" '
        f'viewBox="{x:.4f} {y:.4f} {w:.4f} {h:.4f}"'
    )
    svg = svg[: radice.start()] + nuovo + svg[radice.end():]

    open(percorso, "w", encoding="utf-8").write(svg)
    print(f"  viewBox ritagliato a {w:.1f} x {h:.1f} mm "
          f"(era {vb_w:.1f} x {vb_h:.1f})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
