---
title: "Ambiente di sviluppo"
description: "Una sola definizione degli strumenti, usata in locale e in CI."
---

# Ambiente di sviluppo

Gli strumenti che servono a verificare schema, contenitore e documentazione
sono dichiarati nel `Dockerfile` nella radice del repo. Uno solo, e lo usano
sia la CI sia chi sviluppa.

## Usarlo in locale

```bash
podman run --rm -v "$PWD":/p:Z -w /p \
  ghcr.io/cagianx/pellet-meter-dev ./tools/render.sh
```

Con docker il comando e' lo stesso sostituendo `podman`. Il suffisso `:Z`
sul volume serve con SELinux attivo e non da' fastidio altrove.

Non e' obbligatorio: gli strumenti si possono installare a mano come prima.
Serve quando si vuole **esattamente** l'ambiente della CI — tipicamente per
riprodurre un guasto senza dover indovinare cosa ci fosse nel container.

## Cosa contiene, e perche'

| Strumento | A cosa serve |
|---|---|
| `kicad-cli` | ERC, netlist, export dello schema |
| `openscad` | STL e PNG del contenitore |
| `xvfb` | OpenSCAD vuole un contesto OpenGL anche solo per scrivere un PNG |
| `rsvg-convert` | da SVG a PNG per il README |
| ImageMagick | ritaglio dell'inquadratura, misurato sui pixel |
| `python3` | `crop_svg.py`, `check_case.py`, `check_netlist.py` |
| Node | build del sito docmd |

Il **firmware non sta qui**: usa `espressif/idf:v5.5`. Unire le due catene
raddoppierebbe la dimensione — ESP-IDF porta il toolchain RISC-V completo —
e accoppierebbe cose che cambiano per ragioni diverse: un aggiornamento di
KiCad ricostruirebbe anche il compilatore.

## Aggiungere uno strumento

Si aggiunge al `Dockerfile`, non a un workflow. In fondo al `Dockerfile`
c'e' un controllo che verifica la presenza di tutti gli strumenti attesi:
va aggiornato anche quello, cosi' un pacchetto che cambia nome a monte fa
fallire il build dove si capisce, invece che in un job di render sei
settimane dopo.

L'immagine si ricostruisce da sola quando il `Dockerfile` cambia, e solo
allora.

## Perche' esiste: la catena del guasto

Vale la pena raccontarla, perche' ogni anello era invisibile preso da solo
e perche' e' il motivo per cui le installazioni al volo non si fanno piu'.

Il sito pubblicava un'immagine mancante — `case.png` dava **404** — con la
pipeline **verde**. All'origine:

1. nei job in container, Actions **sceglie la shell da sola**. In quella di
   KiCad sceglieva `sh -e {0}`, cioe' dash, pur essendoci `/usr/bin/bash`
2. sotto dash `compgen` non esiste. La condizione che decideva se
   installare OpenSCAD era `if compgen -G 'enclosure/*.scad'`, e un comando
   inesistente dentro un `if` **non e' un errore**: fa prendere il ramo
   `else`
3. OpenSCAD non veniva installato
4. `render.sh` trattava "manca lo strumento" come un avviso e saltava il
   render
5. nessuno dei passi falliva

Il primo indizio utile non e' stato un messaggio d'errore ma una **durata**:
il passo di installazione durava 3 secondi in tutte le esecuzioni, comprese
quelle che avrebbero dovuto installare OpenSCAD. Installare OpenSCAD non
dura 3 secondi.

Le contromisure sono quattro, a livelli diversi, perche' una sola avrebbe
lasciato il buco aperto da un'altra parte:

- gli strumenti stanno nell'immagine, quindi **non c'e' piu' una
  condizione** da sbagliare
- i job in container dichiarano `defaults.run.shell: bash`, quindi la
  shell non si scopre
- `render.sh --strict`, usato dalla CI, tratta un salto come errore
- il workflow `docs` verifica che ogni immagine referenziata dal sito **e
  dal README** esista e non sia vuota

La lezione generale: **un controllo che puo' saltarsi da solo non e' un
controllo**. Nessuno dei cinque anelli ha prodotto un messaggio rosso.
