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

### Un PNG che non e' vuoto puo' non contenere niente

Il controllo "il file non e' vuoto" copre il caso del contesto OpenGL
mancante, non quello della **scena** vuota. Se un modulo viene rinominato
nel modello e non nel file che lo richiama, OpenSCAD stampa `Ignoring
unknown module`, **esce con successo** e scrive un PNG regolare di qualche
centinaio di byte: solo sfondo.

`render.sh` conta quindi i colori dell'immagine con ImageMagick. Lo sfondo
da solo ne ha uno o due; un render ne ha decine (46–160 per le viste del
contenitore). Sotto gli otto, il render viene considerato vuoto e la
pipeline si ferma.

### Senza font, le quote escono vuote

Stessa famiglia, scoperta col render quotato del contenitore. Se nel
container non ci sono font installati, `text()` **non disegna niente**:
OpenSCAD non avvisa nemmeno su stderr ed esce con successo. Il PNG non e'
vuoto — c'e' la scatola, ci sono le linee di quota — ma i numeri non ci
sono. Nessun controllo sulla dimensione del file se ne accorge.

Non c'e' un avviso da intercettare, quindi `render.sh` chiede a OpenSCAD di
estrudere una riga di cifre in un STL e guarda se ne esce geometria. Prova
la cosa che interessa, cioe' che `text()` funzioni, invece di una sua spia
come "il pacchetto dei font risulta installato". In CI il workflow `docs`
installa `fonts-dejavu-core` insieme a openscad, perche' con
`--no-install-recommends` non arriva nessun font per conto suo.

## Il sito si ripubblica a ogni commit su main

Il workflow `docs` non ha filtri di percorso. E' deliberato: filtrare
sembra un risparmio, ma vuol dire che un commit che tocca solo `firmware/`
o `openspec/` lascia online un sito che descrive lo stato precedente —
e nessuno se ne accorge, perche' la CI e' verde.

Il prezzo e' che il job di render gira anche quando non e' cambiato niente
di grafico: qualche minuto per tirare giu' il container di KiCad. Vale la
pena, perche' l'alternativa e' una documentazione pubblicata che non
corrisponde al repo, che e' esattamente il guasto che queste regole
esistono per evitare.

Lo stesso vale per le pull request: senza filtro, una PR che rompe il sito
si vede prima del merge e non dopo.

## Le immagini referenziate devono esistere

Una pagina che cita un'immagine mancante si costruisce **senza errori**:
docmd non se ne lamenta. Per questo il workflow `docs` raccoglie i
riferimenti ai file che produciamo noi — le immagini e l'STL in
`assets/render/`, il visualizzatore in `assets/js/stl-viewer.js` — nel
sito generato **e nel README**, e controlla che ognuno esista e non sia
vuoto.

Il README e' incluso apposta: punta agli stessi file tramite l'URL di
GitHub Pages, quindi un'immagine che serve solo a lui sparirebbe senza che
nessun controllo sul sito se ne accorga.

Due dettagli che il controllo ha dovuto imparare:

- **Il riferimento si risolve rispetto alla pagina che lo contiene**, non
  alla radice del sito. docmd riscrive `href` e `src` di link e immagini
  in percorsi relativi al livello della pagina, ma **lascia stare i tag
  `<script>`**: un percorso con un livello di troppo punta a un file che
  esiste davvero, solo non da li', e confrontandolo con la radice
  risulterebbe a posto.
- **Si guardano solo gli attributi `src` e `href`.** Il nome di un file
  compare anche nel testo delle pagine che lo descrivono, e quello non e'
  un riferimento da risolvere.

Il resto di `assets/` e' roba di docmd e non viene controllato: ne
referenzia anche qualche file che non genera (`docmd-git.js`), e la CI
fallirebbe per un difetto che non e' nostro e che da qui non si corregge.

Come il controllo della netlist, anche questo e' stato provato **sul caso
che deve fallire**: aggiungendo un `../` di troppo al percorso del
visualizzatore nel sito costruito, e verificando che uscisse con codice 1.
Lo stesso per i font, con un `fontconfig` senza nessuna cartella di font.
