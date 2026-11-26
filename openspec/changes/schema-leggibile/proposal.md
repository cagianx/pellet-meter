# Proposal

## Why

Lo schema e' elettricamente verificato ma graficamente inutilizzabile: i
componenti sono ammassati in alto a sinistra con meta' foglio A3 vuoto,
perche' e' stato generato via script per poter verificare le reti da riga di
comando. Chi deve saldare o rivedere il circuito legge lo schema, non la
netlist. In piu' il PDF esiste solo come artefatto della CI, scaricabile solo
da chi ha un account.

## What Changes

- Disposizione dei componenti rivista nella GUI di KiCad, con i blocchi
  funzionali separati e riconoscibili.
- Le note tecniche restano, ma vicine a cio' che commentano.
- Lo schema viene pubblicato come immagine dentro il sito di documentazione,
  senza bisogno di scaricare artefatti.

## Capabilities

### New Capabilities
- `schema-elettrico`: leggibilita' e pubblicazione dello schema.

## Impact

`kicad/pellet-meter.kicad_sch` viene modificato a mano nella GUI: da quel
momento gli script in `kicad/tools/` non vanno piu' rieseguiti sopra, pena la
perdita del lavoro di disposizione. La verifica della netlist resta valida e
deve continuare a passare.
