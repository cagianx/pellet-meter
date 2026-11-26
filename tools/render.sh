#!/usr/bin/env bash
#
# Genera le immagini che il sito e il README pubblicano.
#
# Le uscite finiscono in docs/docs/assets/render/, che NON e' versionata:
# sono file generati, e la regola del repo e' che li produce la CI. Il sito
# le prende da qui perche' docmd copia docs/assets/ dentro site/assets/.
#
# Lo stesso script gira in locale e nel workflow docs: una sola definizione
# di "come si fa un render", non due che divergono.
#
# Quello che non esiste ancora viene saltato con un avviso: oggi e' il caso
# del PCB, che e' deliberatamente rimandato. Quello che esiste ma non si
# riesce a renderizzare e' un errore, e con --strict lo e' sempre.

set -euo pipefail

cd "$(dirname "$0")/.."

OUT=docs/docs/assets/render
mkdir -p "$OUT"

# Con --strict nessun salto e' ammesso: se una sorgente esiste ma manca lo
# strumento per renderizzarla, lo script fallisce invece di avvisare.
# In locale saltare va bene — si lavora alla documentazione senza avere
# KiCad installato. In CI no: un salto diventa un'immagine mancante sul
# sito, con la pipeline verde.
strict=0
[ "${1:-}" = "--strict" ] && strict=1

avvisi=0

nota() {
  if [ "$strict" = 1 ]; then
    echo "  ERRORE: $*"
    exit 1
  fi
  echo "  -> $*"
  avvisi=$((avvisi + 1))
}

# Quello che manca perche' non esiste ancora non e' un errore nemmeno in
# strict: il PCB e il contenitore arrivano quando arrivano.
assente() {
  echo "  -> $*"
  avvisi=$((avvisi + 1))
}

# --- Schema elettrico ------------------------------------------------------

echo "== schema elettrico"
if ! command -v kicad-cli >/dev/null; then
  nota "kicad-cli non trovato, schema saltato."
  nota "in container: podman run --rm -v \"\$PWD\":/p:Z -w /p kicad/kicad:10.0.8-full tools/render.sh"
else
  # --exclude-drawing-sheet toglie cornice e cartiglio: nella pagina web
  # servirebbero solo a rimpicciolire il disegno.
  kicad-cli sch export svg \
    --black-and-white --exclude-drawing-sheet \
    -o "$OUT" kicad/pellet-meter.kicad_sch >/dev/null
  mv "$OUT/pellet-meter.svg" "$OUT/schema.svg"

  # Il PDF tiene la cornice: e' la versione da stampare e da tenere sul
  # banco mentre si salda.
  kicad-cli sch export pdf \
    --black-and-white \
    -o "$OUT/schema.pdf" kicad/pellet-meter.kicad_sch >/dev/null

  # Il sito mostra l'SVG, che si ingrandisce senza sgranare. Il README no:
  # su GitHub le immagini passano da un proxy, e un PNG e' la versione che
  # non puo' non funzionare. Fondo bianco esplicito, perche' l'SVG di KiCad
  # e' tratto nero su niente: su una pagina in tema scuro sparirebbe.
  if ! command -v rsvg-convert >/dev/null; then
    nota "rsvg-convert non trovato: niente PNG per il README."
  else
    rsvg-convert --width 2000 --background-color=white \
      -o "$OUT/schema.png" "$OUT/schema.svg"

    # Il disegno occupa un quarto del foglio A3: pubblicarlo intero vuol
    # dire pubblicare soprattutto spazio bianco. Il ritaglio si misura sui
    # pixel del PNG, non indovinando le coordinate dell'SVG, e poi la
    # stessa finestra viene riportata sul viewBox dell'SVG: cosi' le due
    # immagini inquadrano esattamente la stessa cosa.
    #
    # Questo ritaglia l'inquadratura, non sistema la disposizione: i
    # componenti ammassati in un angolo restano il task 1.4, che e' lavoro
    # da GUI.
    # ImageMagick 7 si chiama 'magick', il 6 'identify'/'convert'. I
    # container Ubuntu hanno ancora il 6: dare per scontato il 7 vorrebbe
    # dire saltare il ritaglio in CI e accorgersene guardando il sito.
    if command -v magick >/dev/null; then
      im_identify() { magick identify "$@"; }
      im_convert() { magick "$@"; }
    elif command -v identify >/dev/null && command -v convert >/dev/null; then
      im_identify() { identify "$@"; }
      im_convert() { convert "$@"; }
    else
      im_identify() { return 1; }
    fi

    if ! im_identify -format "%w" "$OUT/schema.png" >/dev/null 2>&1; then
      nota "ImageMagick non trovato: immagini non ritagliate."
    else
      bbox=$(im_identify -format "%@" "$OUT/schema.png")
      echo "  contenuto: $bbox su $(im_identify -format '%wx%h' "$OUT/schema.png")"

      # Le dimensioni del PNG vanno come due argomenti distinti: la
      # sostituzione non e' fra virgolette apposta.
      # shellcheck disable=SC2046
      python3 tools/crop_svg.py "$OUT/schema.svg" "$bbox" \
        $(im_identify -format '%w %h' "$OUT/schema.png")

      im_convert "$OUT/schema.png" -trim +repage \
        -bordercolor white -border 40 "$OUT/schema.png"
    fi
    echo "  schema.png $(stat -c%s "$OUT/schema.png") byte"
  fi

  echo "  schema.svg $(stat -c%s "$OUT/schema.svg") byte, schema.pdf $(stat -c%s "$OUT/schema.pdf") byte"
fi

# --- Render 3D del PCB -----------------------------------------------------

echo "== PCB"
if ! compgen -G 'kicad/*.kicad_pcb' >/dev/null; then
  assente "nessun .kicad_pcb: il prototipo e' su millefori, il PCB e' rimandato."
elif ! command -v kicad-cli >/dev/null; then
  nota "kicad-cli non trovato, render del PCB saltato."
else
  for lato in top bottom; do
    kicad-cli pcb render \
      --side "$lato" --background opaque --quality high \
      -o "$OUT/pcb-$lato.png" kicad/*.kicad_pcb >/dev/null
    echo "  pcb-$lato.png $(stat -c%s "$OUT/pcb-$lato.png") byte"
  done
fi

# --- Contenitore -----------------------------------------------------------

echo "== contenitore"
if ! compgen -G 'enclosure/*.scad' >/dev/null; then
  assente "nessun .scad: il contenitore non e' ancora stato disegnato."
elif ! command -v openscad >/dev/null; then
  nota "openscad non trovato, render del contenitore saltato."
else
  # Il render PNG di OpenSCAD ha bisogno di un contesto OpenGL, che in CI
  # non c'e'. Senza display serve un server X virtuale.
  if [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    oscad=(openscad)
  elif command -v xvfb-run >/dev/null; then
    oscad=(xvfb-run -a openscad)
  else
    oscad=()
  fi

  if [ ${#oscad[@]} -eq 0 ]; then
    nota "niente display e niente xvfb-run: render del contenitore saltato."
  else
    for f in enclosure/*.scad; do
      nome=$(basename "$f" .scad)
      # --render forza la geometria esatta invece dell'anteprima rapida:
      # l'anteprima mostra artefatti sulle intersezioni.
      # --autocenter e --viewall inquadrano il pezzo: senza, la camera di
      # default lo taglia o lo lascia lontano.
      # stderr va in un file invece che a schermo: OpenSCAD stampa pagine
      # di statistiche della cache CGAL anche quando tutto va bene. Il
      # file viene mostrato solo se qualcosa non torna, dove serve.
      log=$(mktemp)
      "${oscad[@]}" --render \
        --imgsize=1600,1200 \
        --colorscheme=Tomorrow \
        --autocenter --viewall \
        -o "$OUT/$nome.png" "$f" >/dev/null 2>"$log" || true

      # OpenSCAD esce con codice 0 anche quando non riesce ad aprire il
      # contesto OpenGL: stampa l'errore e scrive un PNG da zero byte.
      # Fidarsi del codice di uscita vuol dire pubblicare un'immagine
      # rotta con la CI verde — e' gia' successo.
      if [ ! -s "$OUT/$nome.png" ]; then
        echo "ERRORE: $nome.png e' vuoto. Il render e' fallito nonostante"
        echo "        openscad sia uscito con successo. Output:"
        sed 's/^/        /' "$log"
        rm -f "$log"
        exit 1
      fi
      rm -f "$log"
      echo "  $nome.png $(stat -c%s "$OUT/$nome.png") byte"
    done
  fi
fi

echo
if [ "$avvisi" -gt 0 ]; then
  echo "fatto, con $avvisi cosa(e) saltata(e)."
else
  echo "fatto, tutto renderizzato."
fi
