#!/usr/bin/env bash
#
# Genera le immagini — e l'STL del visualizzatore — che il sito e il README
# pubblicano.
#
# Le uscite finiscono in docs/docs/assets/render/, che NON e' versionata:
# sono file generati, e la regola del repo e' che li produce la CI. Il sito
# le prende da qui perche' docmd copia docs/assets/ dentro site/assets/.
#
# Lo stesso script gira in locale e nel workflow docs: una sola definizione
# di "come si fa un render", non due che divergono.
#
# Quello che non esiste ancora viene saltato con un avviso; oggi non manca
# niente. Quello che esiste ma non si riesce a renderizzare e' un errore, e
# con --strict lo e' sempre.

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

# --- Cosa c'e' in questo ambiente ------------------------------------------
#
# Stampato sempre, anche quando va tutto bene. Quando qualcosa salta, la
# prima domanda e' "che strumenti aveva a disposizione?", e la risposta
# deve stare nello stesso log invece di richiedere un'altra esecuzione.

echo "== strumenti"
for t in kicad-cli openscad rsvg-convert magick convert identify python3 xvfb-run; do
  if percorso=$(command -v "$t" 2>/dev/null); then
    printf "  %-13s %s\n" "$t" "$percorso"
  else
    printf "  %-13s ASSENTE\n" "$t"
  fi
done
printf "  %-13s %s\n" "display" "${DISPLAY:-${WAYLAND_DISPLAY:-nessuno}}"
printf "  %-13s %s\n" "strict" "$strict"
echo

# ImageMagick 7 si chiama 'magick', il 6 'identify'/'convert'. I container
# Ubuntu hanno ancora il 6: dare per scontato il 7 vorrebbe dire saltare i
# controlli sulle immagini in CI e accorgersene guardando il sito.
# Serve sia allo schema (ritaglio) sia al contenitore (scena non vuota),
# quindi la scelta si fa una volta sola, qui.
if command -v magick >/dev/null; then
  im_identify() { magick identify "$@"; }
  im_convert() { magick "$@"; }
elif command -v identify >/dev/null && command -v convert >/dev/null; then
  im_identify() { identify "$@"; }
  im_convert() { convert "$@"; }
else
  im_identify() { return 1; }
fi

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
  assente "nessun .kicad_pcb: il PCB non e' ancora stato disegnato."
elif ! command -v kicad-cli >/dev/null; then
  nota "kicad-cli non trovato, render del PCB saltato."
else
  pcb=$(echo kicad/*.kicad_pcb)

  # vista_pcb <nome> <argomenti di kicad-cli pcb render>
  #
  # Le quattro inquadrature mostrano cose diverse. Una in piu' costa un
  # render intero e, se non aggiunge niente, costringe solo a guardare due
  # volte la stessa scheda.
  #
  #   sopra    la disposizione: modulo, partitore, ponticello, foro ottico
  #   sotto    il rame del lato B e le piazzole passanti
  #   tre quarti  l'assieme con l'altezza del modulo innestato
  #   di lato  quanto e' alto l'assieme, che e' il vincolo del contenitore
  vista_pcb() {
    local nome=$1
    shift
    kicad-cli pcb render --background opaque --quality high \
      "$@" -o "$OUT/$nome.png" "$pcb" >/dev/null

    if [ ! -s "$OUT/$nome.png" ]; then
      echo "ERRORE: $nome.png e' vuoto."
      exit 1
    fi
    # Stesso controllo del contenitore: un'immagine di solo sfondo pesa
    # comunque qualche kilobyte, e la dimensione non la vede.
    if colori=$(im_identify -format "%k" "$OUT/$nome.png" 2>/dev/null); then
      if [ "$colori" -le 8 ]; then
        echo "ERRORE: $nome.png ha $colori colore(i): la scena e' vuota."
        exit 1
      fi
    else
      colori="?"
    fi
    echo "  $nome.png $(stat -c%s "$OUT/$nome.png") byte, $colori colori"
  }

  vista_pcb pcb-top        --side top
  vista_pcb pcb-bottom     --side bottom
  vista_pcb pcb-3d         --rotate '-35,0,30' --perspective --floor --zoom 0.8
  vista_pcb pcb-lato       --side front --zoom 1.3

  # Il modello a colori, per chi lo vuole aprire in un programma 3D. I
  # componenti marcati DNP restano fuori: la configurazione di default e'
  # senza MOSFET, e un modello che lo mostra montato racconta una scheda
  # diversa da quella che si costruisce.
  kicad-cli pcb export glb --no-dnp --force \
    -o "$OUT/pcb.glb" "$pcb" >/dev/null
  echo "  pcb.glb $(stat -c%s "$OUT/pcb.glb") byte"

  # L'STL che il visualizzatore del sito carica. kicad-cli lo scrive in
  # ASCII e il visualizzatore vuole il binario, che pesa un quinto: la
  # conversione e' in tools/stl_bin.py.
  kicad-cli pcb export stl --no-dnp --force \
    -o "$OUT/pcb-ascii.stl" "$pcb" >/dev/null
  python3 tools/stl_bin.py "$OUT/pcb-ascii.stl" "$OUT/pcb.stl"
  rm -f "$OUT/pcb-ascii.stl"
  echo "  pcb.stl $(stat -c%s "$OUT/pcb.stl") byte"
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
    # Sorgenti gia' coperti da una vista scelta: quelli che restano fuori
    # vengono renderizzati lo stesso, con l'inquadratura automatica.
    coperti=""
    im_avvisato=0

    # vista <nome> <sorgente> <elevazione> <azimut> <proiezione> [extra...]
    #
    # --camera vuole translate_x,y,z,rot_x,y,z,dist, ma translate e dist
    # restano a zero: li ricalcolano --autocenter e --viewall sul pezzo
    # vero, cosi' una quota che cambia non lascia il render tagliato o
    # lontano. A mano restano i due angoli e nient'altro.
    #
    #   elevazione  0 = dall'alto, 90 = di fianco, 180 = dal basso
    #   azimut      0 = si guarda la parete y=0; crescendo si gira attorno
    #               al pezzo in senso antiorario
    #   proiezione  p = prospettica (le viste di forma), o = ortogonale
    #               (le quote: in prospettiva una quota misura male)
    vista() {
      local nome=$1 sorgente=$2 elev=$3 azim=$4 proiezione=$5
      shift 5
      coperti="$coperti $sorgente"

      # --render forza la geometria esatta invece dell'anteprima rapida:
      # l'anteprima mostra artefatti sulle intersezioni.
      # stderr va in un file invece che a schermo: OpenSCAD stampa pagine
      # di statistiche della cache CGAL anche quando tutto va bene. Il
      # file viene mostrato solo se qualcosa non torna, dove serve.
      local log
      log=$(mktemp)
      "${oscad[@]}" --render \
        --imgsize=1600,1200 \
        --colorscheme=Tomorrow \
        --projection="$proiezione" \
        --camera="0,0,0,$elev,0,$azim,0" \
        --autocenter --viewall \
        "$@" \
        -o "$OUT/$nome.png" "$sorgente" >/dev/null 2>"$log" || true

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

      # Un PNG pieno di solo sfondo pesa comunque qualche centinaio di
      # byte, quindi il controllo sulla dimensione non lo vede. Succede
      # ogni volta che la scena esce vuota: un modulo rinominato in
      # case.scad e non qui, per esempio, fa stampare un avviso a OpenSCAD
      # e produce un'immagine bianca, con la CI verde.
      # Lo sfondo da solo ha uno o due colori; un render, decine.
      if colori=$(im_identify -format "%k" "$OUT/$nome.png" 2>/dev/null); then
        if [ "$colori" -le 8 ]; then
          echo "ERRORE: $nome.png ha $colori colore(i): la scena e' vuota."
          echo "        Il file c'e' e non e' vuoto, ma non c'e' il pezzo."
          sed 's/^/        /' "$log"
          rm -f "$log"
          exit 1
        fi
      else
        colori="?"
        if [ "$im_avvisato" = 0 ]; then
          im_avvisato=1
          nota "ImageMagick non trovato: non si controlla se la scena e' vuota."
        fi
      fi

      rm -f "$log"
      echo "  $nome.png $(stat -c%s "$OUT/$nome.png") byte, $colori colori"
    }

    # Le quote sono testo, e senza font installati text() non disegna
    # niente: OpenSCAD non avvisa, esce con successo, e il render quotato
    # viene fuori con le linee di quota e senza numeri. E' stato provato
    # con un fontconfig vuoto, ed e' andata esattamente cosi'.
    #
    # Non c'e' un avviso da intercettare, quindi si chiede a OpenSCAD di
    # produrre del testo e si guarda se ne esce geometria. Questo prova la
    # cosa che interessa — text() funziona — invece di una sua spia, tipo
    # "il pacchetto dei font risulta installato".
    sonda=$(mktemp --suffix=.scad)
    sonda_stl=$(mktemp -u --suffix=.stl)
    echo 'linear_extrude(1) text("0123456789", size = 10);' > "$sonda"
    "${oscad[@]}" -o "$sonda_stl" --export-format asciistl "$sonda" \
      >/dev/null 2>&1 || true
    if ! grep -q facet "$sonda_stl" 2>/dev/null; then
      echo "ERRORE: text() non produce geometria: mancano i font."
      echo "        Il render quotato uscirebbe con le linee di quota e"
      echo "        senza numeri, senza che niente fallisca."
      rm -f "$sonda" "$sonda_stl"
      exit 1
    fi
    rm -f "$sonda" "$sonda_stl"

    # Le angolazioni sono quattro, scelte perche' mostrano cose diverse:
    # una vista in piu' costa un render intero e, se non aggiunge niente,
    # costringe solo a guardare due volte la stessa scatola.
    #
    # tre quarti   i due vani, il divisorio e il labbro del coperchio
    # dal basso    foro ottico svasato e faccia di incollaggio (il pezzo e'
    #              capovolto nel modello, vedi viste/case-sotto.scad)
    # lato USB-C   l'apertura sulla parete corta e il tappo parcheggiato,
    #              che dall'alto si intuiscono appena
    # coperchio    le finestre dei dentini e la luce per la USB-C, che
    #              stanno tutte sulla faccia inferiore del coperchio
    vista case          enclosure/case.scad             60  30 p
    vista case-sotto    enclosure/viste/case-sotto.scad 60 210 p
    vista case-usb      enclosure/case.scad             80 250 p \
                        -D 'pezzo="scatola"'
    vista case-coperchio enclosure/viste/case-coperchio.scad 55 210 p
    # La quarta non e' un'angolazione in piu': e' la stessa scatola con le
    # quote d'ingombro, che vengono dai parametri del modello.
    vista case-quote    enclosure/viste/case-quote.scad 60  30 o

    # Un .scad che nessuna vista nomina viene comunque pubblicato, con
    # l'inquadratura automatica: meglio un render generico che nessun
    # render, e l'avviso ricorda a chi aggiunge un pezzo di scegliergli
    # un'angolazione.
    for f in enclosure/*.scad; do
      case " $coperti " in *" $f "*) continue;; esac
      echo "  $f non ha una vista scelta: inquadratura automatica."
      vista "$(basename "$f" .scad)" "$f" 60 30 p
    done

    # L'STL che il visualizzatore del sito carica. E' lo stesso solido dei
    # render, non un'esportazione a parte: se il modello non si chiude, qui
    # si vede subito. binstl perche' pesa un terzo dell'ASCII, e il
    # visualizzatore lo scarica a ogni apertura della pagina.
    "${oscad[@]}" --export-format binstl \
      -o "$OUT/case.stl" enclosure/case.scad >/dev/null 2>&1 || true
    if [ ! -s "$OUT/case.stl" ]; then
      echo "ERRORE: case.stl e' vuoto: il visualizzatore non avrebbe niente"
      echo "        da mostrare, e la pagina resterebbe muta."
      exit 1
    fi
    echo "  case.stl $(stat -c%s "$OUT/case.stl") byte"
  fi
fi

echo
if [ "$avvisi" -gt 0 ]; then
  echo "fatto, con $avvisi cosa(e) saltata(e)."
else
  echo "fatto, tutto renderizzato."
fi
