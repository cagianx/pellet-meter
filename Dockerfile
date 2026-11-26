# Ambiente di sviluppo e di verifica del pellet-meter.
#
# Una sola definizione degli strumenti, usata sia in CI sia in locale.
# Prima erano tre — le righe apt-get nei workflow, le istruzioni in docs/ e
# quello che ciascuno aveva installato — e la divergenza e' gia' costata
# un'immagine rotta pubblicata con la pipeline verde.
#
# Uso in locale:
#   podman run --rm -v "$PWD":/p:Z -w /p ghcr.io/cagianx/pellet-meter-dev ./tools/render.sh
#
# Il firmware NON sta qui: usa espressif/idf:v5.5, che e' gia' un'immagine
# sola e fissata. Unire le due catene raddoppierebbe la dimensione e
# accoppierebbe cose che cambiano per ragioni diverse.

# Stessa versione di KiCad usata in sviluppo: una CI che vede un KiCad
# diverso e' il guasto che questa scelta esiste per evitare, e i problemi
# di formato dei file KiCad dipendono dalla versione.
FROM kicad/kicad:10.0.8-full

USER root

# DEBIAN_FRONTEND evita i messaggi di debconf su un terminale che non c'e'.
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        # render STL e PNG del contenitore
        openscad \
        # OpenSCAD vuole un contesto OpenGL anche solo per scrivere un PNG:
        # senza display scrive un file da zero byte ed esce con successo
        xvfb \
        # da SVG a PNG per il README, che non puo' usare percorsi relativi
        librsvg2-bin \
        # ritaglio dell'inquadratura, misurato sui pixel
        imagemagick \
        # crop_svg.py, check_case.py, check_netlist.py
        python3 \
        # build del sito docmd
        nodejs npm \
        git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Verifica che l'immagine contenga davvero quello che dichiara. Un
# pacchetto che cambia nome a monte farebbe fallire il build qui, dove si
# capisce, invece che in un job di render sei settimane dopo.
RUN set -eux; \
    for t in kicad-cli openscad xvfb-run rsvg-convert convert identify python3 node npm git; do \
        command -v "$t" >/dev/null || { echo "manca nell'immagine: $t"; exit 1; }; \
    done; \
    kicad-cli version; \
    openscad --version; \
    python3 --version; \
    node --version

# Il repo viene montato qui dai workflow e dall'uso locale.
WORKDIR /work

CMD ["/bin/bash"]
