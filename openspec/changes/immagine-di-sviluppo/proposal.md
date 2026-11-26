# Proposal

## Why

Gli strumenti necessari a verificare questo progetto sono oggi definiti in
tre posti che possono divergere: le righe `apt-get` dentro i workflow, le
istruzioni in `docs/`, e quello che ciascuno ha installato sulla propria
macchina. Non e' un rischio teorico: e' gia' costato un'immagine rotta
pubblicata con la CI verde.

La catena era questa, e ogni anello era invisibile:

1. nei job in container Actions sceglieva `sh` invece di `bash`
2. sotto `sh`, `compgen` non esiste, quindi la condizione che decideva se
   installare OpenSCAD prendeva il ramo `else`
3. OpenSCAD non veniva installato
4. il render del contenitore veniva saltato con un avviso
5. il sito pubblicava un'immagine mancante, con la pipeline verde

Un ambiente dichiarato una volta sola e costruito da un `Dockerfile`
versionato rimuove i primi tre anelli invece di tamponarli: non c'e' piu'
un'installazione condizionale da sbagliare, perche' gli strumenti ci sono
gia'.

In piu' da' a chi sviluppa lo stesso ambiente della CI senza installare
niente sulla propria macchina — oggi per riprodurre un guasto della CI
bisogna indovinare cosa c'e' nel container.

## What Changes

- `Dockerfile` versionato con la catena di strumenti di hardware e
  documentazione: KiCad, OpenSCAD, xvfb, librsvg, ImageMagick, Python,
  Node.
- Immagine costruita e pubblicata su GHCR solo quando il `Dockerfile`
  cambia, non a ogni commit.
- I workflow `hardware` e `docs` girano in quell'immagine, senza piu'
  installare pacchetti al volo.
- Un modo documentato per usare la stessa immagine in locale.

## Capabilities

### New Capabilities
- `ambiente-di-sviluppo`: la catena di strumenti riproducibile, condivisa
  tra chi sviluppa e la CI.

## Impact

Nuovo `Dockerfile` e nuovo workflow che pubblica l'immagine. I workflow
`hardware` e `docs` perdono i passi di installazione.

Il firmware resta fuori: continua a usare `espressif/idf:v5.5`, che e' gia'
un'immagine sola e fissata. Vedi design.md.
