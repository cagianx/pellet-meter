---
title: "Come si verifica"
description: "Perche' l'ERC pulito non basta, e cosa controlla davvero la CI."
---

# Come si verifica

## L'ERC pulito non basta

Questo e' il punto piu' importante della pagina.

L'ERC controlla le **regole elettriche**: pin scollegati, alimentazioni non
pilotate, conflitti di tipo. Non controlla che le reti siano quelle che
volevi.

Un errore di battitura in un'etichetta — `SDA` scritto `SAD` su un pin solo —
produce due reti a un nodo invece di una rete a due nodi. Se entrambi i pin
sono passivi, **l'ERC non dice niente**. Lo schema risulta pulito e il
circuito e' sbagliato.

Per questo esiste `kicad/tools/check_netlist.py`, che confronta la netlist
esportata con la connettivita' attesa, nodo per nodo:

```bash
cd kicad
kicad-cli sch export netlist --format kicadsexpr -o out/pm.net pellet-meter.kicad_sch
python3 tools/check_netlist.py out/pm.net
```

Verifica anche che i pin **lasciati scollegati di proposito** siano
esattamente quelli previsti: se domani qualcuno collega un pin libero senza
aggiornare l'atteso, il controllo lo segnala.

:::note
**Un controllo va provato anche sul caso che deve fallire.** Quello di questo
repo e' stato verificato sabotando la netlist (rinominando una rete) e
controllando che uscisse con codice 1. Un controllo che passa sempre non vale
niente, e non c'e' modo di accorgersene guardando solo i successi.
:::

## Stato atteso delle reti

| Rete | Nodi |
|---|---|
| `GND` | 9 |
| `BAT_SENSE` | 4 |
| `VSENS` | 4 |
| `VBAT` | 3 |
| `SDA`, `SCL`, `XSHUT` | 2 ciascuna |

Piu' 16 pin deliberatamente scollegati. Qualunque scostamento fa fallire la CI.

## Cosa fa la CI

Il workflow `hardware` gira nell'immagine **`kicad/kicad:10.0.8-full`**, cioe'
la stessa versione usata in sviluppo. E' una scelta deliberata: con un PPA si
rischia che la CI veda un KiCad diverso da quello locale, e i problemi di
formato dipendono dalla versione.

| Passo | Cosa fa |
|---|---|
| ERC | `--severity-error --severity-warning --exit-code-violations` |
| Netlist | esporta e verifica le reti attese |
| Export | PDF, SVG e distinta componenti |
| Contenitore | render STL, piu' `check_case.py` sulle quote |

L'ERC fallisce **anche sui warning**. E' sostenibile perche' lo schema e' a
zero violazioni: qualunque regressione si vede subito, invece di accumularsi
sotto la soglia dell'attenzione.

## OpenSCAD esce con successo anche quando fallisce

Questa e' costata un'immagine rotta pubblicata con la CI verde, e vale la
pena saperla prima di rifare lo stesso errore.

Il render **PNG** di OpenSCAD ha bisogno di un contesto OpenGL. In CI non
c'e' un display, quindi non riesce ad aprirlo. Quello che fa in quel caso
non e' fallire:

```
Unable to open a connection to the X server.
Can't create OpenGL OffscreenView. Code: -1.
$ echo $?
0
```

Scrive un **PNG da zero byte** ed esce con **codice 0**. Il job resta verde,
l'artefatto viene caricato, e il buco si vede solo aprendo il sito.

Due accorgimenti, perche' uno solo non basta:

- in CI il render gira sotto **`xvfb-run`**, che fornisce il display mancante
- `tools/render.sh` controlla comunque che ogni PNG **non sia vuoto** e
  fallisce se lo e'

Lo stesso vale per gli STL, per cui il controllo "il file esiste e non e'
vuoto" c'era gia': il codice di uscita di OpenSCAD non e' una fonte
affidabile di verita'.

## Le immagini referenziate devono esistere

Una pagina che cita un'immagine mancante si costruisce **senza errori**:
docmd non se ne lamenta. Per questo il workflow `docs` raccoglie tutti i
riferimenti ad `assets/render/` nel sito generato **e nel README**, e
controlla che ogni file esista e non sia vuoto.

Il README e' incluso apposta: punta agli stessi file tramite l'URL di
GitHub Pages, quindi un'immagine che serve solo a lui sparirebbe senza che
nessun controllo sul sito se ne accorga.
