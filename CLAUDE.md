# pellet-meter

Sensore di livello del pellet a batteria. Misura con un sensore ToF laser la
distanza dal coperchio alla superficie del pellet nella tramoggia della stufa,
e la trasmette a Home Assistant via BLE advertising in formato **BTHome v2**,
insieme allo stato della batteria. Si risveglia, misura, trasmette e torna in
deep sleep.

Hardware: **Seeed XIAO ESP32C6** + **VL53L1X** (ToF, I²C) + LiPo 1000 mAh.

## Struttura

```
kicad/              progetto KiCad 10
  pellet-meter.kicad_sch    schema elettrico (fonte di verita')
  lib/                      simboli e footprint di progetto
  tools/                    script che hanno generato lo schema (bootstrap)
  out/                      PDF/SVG esportati — generati, non versionati
enclosure/          contenitore parametrico OpenSCAD
docs/               sito di documentazione (docmd) pubblicato su GitHub Pages
```

## Comandi di verifica

Eseguirli dalla cartella indicata. **L'ERC pulito non basta**: verificare
sempre anche la netlist, perche' un errore di battitura in un'etichetta crea
una rete isolata senza necessariamente far scattare un errore.

```bash
# ERC — dalla cartella kicad/
kicad-cli sch erc -o erc.rpt pellet-meter.kicad_sch

# netlist, per controllare le reti nodo per nodo
kicad-cli sch export netlist --format kicadsexpr -o out/pellet-meter.net pellet-meter.kicad_sch

# PDF e SVG dello schema
kicad-cli sch export pdf --black-and-white -o out/pellet-meter-schema.pdf pellet-meter.kicad_sch

# STL del contenitore — dalla cartella enclosure/
openscad -o out/case.stl case.scad
```

Le reti attese sono 7: `GND` (9 nodi), `BAT_SENSE` (4), `VSENS` (4),
`VBAT` (3), `SDA` (2), `SCL` (2), `XSHUT` (2). Tutto il resto deve risultare
come rete a nodo singolo, e corrisponde ai pin marcati esplicitamente come
non collegati.

## Scelte di progetto da non ribaltare per distrazione

- **La calibrazione sta in Home Assistant, non nel firmware.** Il firmware
  trasmette la distanza grezza in mm; ricalibrare non deve richiedere un
  reflash.
- **Il sensore e' alimentato direttamente dal GPIO D2**, senza MOSFET. E' una
  decisione presa consapevolmente: un SOT-23 su millefori richiederebbe un
  adattatore, e il prototipo serve proprio a misurare se il problema esiste.
  L'upgrade a P-MOSFET high-side e' annotato sullo schema, da fare solo se le
  misure mostrano cali di tensione. **Con il MOSFET la logica si inverte**:
  D2 basso = sensore acceso.
- **Il partitore della batteria e' 2×1 MΩ**, non 100 kΩ. A 4,2 V sono ~2,1 µA
  contro ~21 µA, e con 100 kΩ si raddoppierebbe il consumo in deep sleep.
  L'impedenza alta (500 kΩ) e' la ragione del C1 da 100 nF.
- **I pull-up I²C del breakout sono alimentati dalla rete VSENS.** Prima del
  deep sleep, SDA/SCL/XSHUT vanno messi in uno stato che non faccia passare
  corrente nel sensore spento attraverso quelle linee.
- **Lo XIAO ESP32C6 ha uno switch RF su GPIO interni** (non esposti sui 14 pin
  del connettore, quindi non compaiono sullo schema). Vanno impostati **a ogni
  risveglio**, prima di inizializzare il BLE, altrimenti l'advertising esce
  attenuato.

## Trappole del formato KiCad 10 (scoperte sul campo)

Servono se si rigenera lo schema via script. KiCad, davanti a un file
malformato, dice solo `Fallito caricamento schema` senza riga ne' motivo:
queste sono le cause trovate finora.

- La versione del formato schema e' `20260306`, `generator_version "10.0"`.
  Un file dichiarato come KiCad 9 non accetta i simboli delle librerie di
  sistema, che sono in formato 10.
- Dentro `(lib_symbols)` **solo il simbolo padre prende il prefisso
  `Libreria:Nome`**. Le sotto-unita' (`Nome_0_1`, `Nome_1_1`) vanno lasciate
  col nome originale. Rinominarle fa fallire il caricamento.
- Nelle stringhe quotate i ritorni a capo vanno scritti come escape `\n`.
  Un newline vero fa fallire il caricamento.
- L'asse Y e' **invertito** tra libreria dei simboli e schema: la posizione di
  un pin nello schema e' `(X + px, Y − py)`.
- La griglia di connessione e' ancorata a zero: le coordinate devono essere
  multipli di **1,27 mm**, altrimenti l'ERC segnala `endpoint_off_grid`.
- I simboli derivati usano `(extends "Padre")` e **non ripetono i pin**: chi
  legge la libreria deve seguire `extends`, altrimenti ottiene zero pin e
  genera uno schema senza quei collegamenti, in silenzio.
- Le librerie di sistema si referenziano con `${KICAD10_SYMBOL_DIR}` e
  `${KICAD10_FOOTPRINT_DIR}`, quelle di progetto con `${KIPRJMOD}`.

## Regole

Due regole non negoziabili, perche' il lavoro su questo progetto e' distribuito
su conversazioni diverse che non condividono memoria: il repo e' l'unico punto
di passaggio.

1. **Il know-how va conservato in `docs/`.** Tutto quello che si impara
   lavorando — perche' una scelta e' stata fatta, cosa e' stato provato e non
   funziona, le trappole degli strumenti, i numeri misurati — finisce nel sito
   di documentazione, non solo nei messaggi di commit o in una conversazione.
   Se una cosa e' stata capita e non e' scritta in `docs/`, e' persa.

2. **Le modifiche passano per OpenSpec.** Prima si propone un change in
   `openspec/changes/<nome>/` con proposal, spec, design e task; poi si
   implementa; poi si archivia aggiornando le spec in `openspec/specs/`.
   Non si inizia a modificare il progetto senza un change che dica cosa si sta
   cambiando e perche'. Le correzioni banali e il lavoro gia' tracciato nei
   task di un change aperto non richiedono un change nuovo.

## Convenzioni di lavoro

- Commit frequenti; push quando si arriva a un punto stabile e verificato.
- Quando piu' agenti lavorano in parallelo, **committare con path espliciti**
  (`git add kicad/`), mai `git add -A`: si rischia di portarsi dietro il
  lavoro a meta' di qualcun altro.
- Non versionare le uscite generate: `kicad/out/`, `enclosure/out/`, i report
  `.rpt`, i `__pycache__`. Le produce la CI.
- Documentazione e commenti in italiano.
- Gli script in `kicad/tools/` hanno generato lo schema iniziale. Una volta
  modificato lo schema nella GUI, **il `.kicad_sch` e' la fonte di verita'**:
  non rieseguire i generatori sopra modifiche fatte a mano senza prima
  guardare il diff.
