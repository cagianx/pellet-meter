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
| Contenitore | render STL — si salta da solo se non ci sono file `.scad` |

L'ERC fallisce **anche sui warning**. E' sostenibile perche' lo schema e' a
zero violazioni: qualunque regressione si vede subito, invece di accumularsi
sotto la soglia dell'attenzione.

Per gli STL il controllo non si ferma al codice di uscita di OpenSCAD, che
non segnala tutti i problemi: verifica anche che il file esista e non sia
vuoto.
