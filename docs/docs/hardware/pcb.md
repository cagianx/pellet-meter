---
title: "Circuito stampato"
description: "Il PCB a due strati: doppia configurazione dell'alimentazione, modelli 3D e accoppiamento col contenitore."
---

# Circuito stampato

`kicad/pellet-meter.kicad_pcb`, due strati, **50 × 34 mm**. Lo schema resta
la fonte di verita': il PCB importa le reti dalla netlist e la CI verifica
che le due cose combacino.

<img src="/assets/render/pcb-3d.png" alt="Render tridimensionale della scheda con il modulo innestato"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

:::warning
**La scheda, cosi' com'e', non entra nel contenitore attuale**: eccede di
**8,2 mm in altezza**. Non e' una svista, e' il prezzo del modulo
innestato. Il numero e cosa comporta stanno in
[Accoppiamento col contenitore](#accoppiamento-col-contenitore).
:::

## Il motivo per cui questa scheda esiste adesso

Il PCB era stato **deliberatamente rimandato**, e la ragione era buona: il
rame congela l'unica scelta hardware ancora aperta, cioe' se il sensore va
alimentato direttamente dal GPIO o tramite un interruttore a MOSFET. Quella
scelta la chiudono le misure sul banco, che nessuno ha ancora fatto.

Il rinvio e' stato ribaltato perche' si e' trovato il modo di non
riprendersi il problema: **sul rame ci sono tutte e due le configurazioni**,
e si sceglie con una goccia di stagno.

## Le due configurazioni dell'alimentazione

| | Ponticello JP1 | Q1 e R3 | D2 alto | D2 basso |
|---|---|---|---|---|
| **Diretta** (default) | 1-2 | non montati | sensore **acceso** | sensore spento |
| **MOSFET** | 2-3 | montati | sensore spento | sensore **acceso** |

**Fra le due la logica di D2 si inverte.** Non e' un dettaglio: montare il
MOSFET e dimenticarsene produce un sensore che non si accende mai, e sul
banco sembra un sensore guasto. Per questo la configurazione va dichiarata
anche nel firmware come scelta esplicita a compile time, con il default
allineato al default del rame.

Il default e' la **configurazione diretta**, cioe' quella del prototipo su
millefori: chi costruisce parte da quello che e' gia' stato verificato.
Q1 e R3 sono marcati DNP sullo schema, e il render li mostra come sagome
vuote.

Il ponticello e' a tre piazzole da saldare, non un pettine con jumper:
un pettine aggiunge un componente, dell'altezza e un contatto che in una
stufa puo' allentarsi per vibrazione. Esce di fabbrica **aperto**, quindi
la configurazione di default richiede comunque una goccia di stagno fra 1
e 2 — la serigrafia accanto a JP1 dice `1-2 DIR  2-3 FET`.

Le reti coinvolte, che sullo schema non c'erano:

| Rete | Da dove a dove |
|---|---|
| `SENS_CTRL` | D2 → gate di Q1, R3, JP1 pad 1 |
| `SW_OUT` | drain di Q1 → JP1 pad 3 |
| `3V3_OUT` | pin 12 dello XIAO → source di Q1, R3 |

## Com'e' disposta

<img src="/assets/render/pcb-top.png" alt="Lato componenti della scheda"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

Il modulo XIAO sta a sinistra, **innestato su due header femmina** e con
l'USB-C verso il bordo corto, dove il contenitore ha la sua apertura. Il
breakout del sensore sta a destra, anch'esso su header, e guarda in basso
attraverso un **foro da 5 mm** ricavato nella scheda: il cono di misura
del VL53L1X e' di 27°, che a 8,5 mm dal sensore fa 4,1 mm di diametro.

Il partitore della batteria — R1, R2, C1 — sta sotto il modulo, a ridosso
del pin ADC: e' la rete piu' sensibile della scheda e l'impedenza e' alta
(500 kΩ), quindi il percorso va tenuto corto.

I due condensatori di sostegno di `VSENS`, C2 e C3, stanno vicino al pin
VIN del breakout, dove servono.

### Le dieci piazzole in piu' del footprint dello XIAO

Il modulo espone sul **fondo** i pin 15-22 (debug) e i pad della batteria.
Con il modulo innestato su un header, da quelle piazzole non ci si arriva
col rame. Senza una piazzola corrispondente, pero', il DRC con
`--schematic-parity` segnala pin dello schema che la scheda non ha.

La scheda le porta quindi come **piazzole di servizio** per fili volanti.
Due servono davvero: `B+` e `B-`, perche' la batteria arriva ai pad sul
fondo del modulo e non passa dall'header.

### Lato rame posteriore

<img src="/assets/render/pcb-bottom.png" alt="Lato opposto della scheda"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

Non c'e' un piano di massa: `GND` e' sbrogliata come tutte le altre reti.
Su una scheda con dieci reti e l'antenna a 10 mm dal rame, su un modulo
che ha il suo piano di massa a bordo, un piano qui sotto non aggiungeva
niente e complicava la verifica — una zona che si frammenta produce isole
isolate che il DRC segnala, e vanno inseguite a mano.

## Modelli 3D: quali sono veri e quali no

Questo e' il punto in cui un render inganna piu' facilmente, quindi vale
la pena dirlo per esteso.

| Componente | Modello |
|---|---|
| R1, R2, R3, C1, C2, C3, BT1, U2 (header), Q1 | **reali**, dalle librerie KiCad |
| U1, modulo XIAO | **sostituto**: tre parallelepipedi con le quote d'ingombro |
| U2, corpo del breakout VL53L1X | **assente** in KiCad, aggiunto solo nella verifica di accoppiamento |

**Perche' lo XIAO ha un sostituto.** Il footprint portava i modelli STEP di
cinque altri XIAO sotto `${AMZPATH}`, una variabile che il progetto non
definisce e che punta a una libreria di terze parti. Nessuno di quei file
esiste in locale ne' nell'immagine `kicad/kicad:10.0.8-full` usata in CI,
quindi l'idea di "usare un altro XIAO della famiglia come sostituto
geometrico" non era praticabile. Al suo posto c'e'
`kicad/lib/pellet-meter.3dshapes/xiao-esp32-c6-sostituto.wrl`: modulo
21 × 17,5 × 3,5 mm (da datasheet) appoggiato su due file di contatti alte
8,5 mm. **L'header femmina fa parte del solido** anche se non e' un
componente dello schema: e' lui a decidere l'altezza dell'assieme.

**Perche' il breakout non ha corpo.** Sullo schema e' un header a 6 pin, e
in 3D si vede l'header. Il corpo e' un parallelepipedo parametrico aggiunto
dal lato OpenSCAD, con le stesse quote che il contenitore usa per
dimensionare il vano: evita di dover produrre un file a mano e tiene
l'ingombro dove stanno gia' gli altri parametri.

Nel render qui sopra, quindi, **manca la scheda del sensore**: si vedono i
suoi sei pin e basta.

## Vista di lato e modello ruotabile

<img src="/assets/render/pcb-lato.png" alt="La scheda vista di lato: si vede l'altezza dell'assieme"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

La vista di lato e' quella che conta per il contenitore: l'assieme e' alto
**15 mm** da sotto i reofori alla cima del modulo.

<div data-stl-viewer style="background:#f7f7f7;border-radius:6px;padding:1rem">
  <p>
    Modello tridimensionale interattivo: servono JavaScript e WebGL.
    In alternativa si puo'
    <a href="/assets/render/pcb.stl">scaricare l'STL</a>
    e aprirlo in un programma 3D — e le immagini qui sopra restano
    sufficienti a capire forma e ingombro.
  </p>
</div>

Si trascina col mouse o col dito per ruotare, rotella per lo zoom, frecce
da tastiera. E' lo stesso visualizzatore del contenitore, e lo stesso STL
che usa la verifica di accoppiamento: se la scheda cambia, qui si vede.

Esiste anche la versione **a colori e con i materiali**, in formato glTF
binario: [`pcb.glb`](/assets/render/pcb.glb), 420 kB. Il visualizzatore del
sito legge STL e non glTF, quindi quel file e' da scaricare, non da girare
qui dentro.

Entrambi sono esportati con `--no-dnp`: rappresentano la configurazione di
default, senza MOSFET.

## Come si verifica

```bash
# dalla radice del repo
kicad-cli pcb drc \
  --severity-error --severity-warning \
  --schematic-parity --exit-code-violations \
  -o /tmp/drc.rpt kicad/pellet-meter.kicad_pcb

python3 tools/check_fit.py
```

`--schematic-parity` e' la meta' che conta davvero. Il DRC da solo dice che
il layout e' valido, non che e' il layout di **questo** schema: una rete
rimasta indietro supera il DRC senza una parola. Con la parita' attiva,
KiCad confronta reti, footprint, campi e attributo DNP, e segnala anche i
pin dello schema che sul rame non hanno piazzola.

Stato attuale: **0 violazioni, 0 elementi non connessi, 0 problemi di
parita'**.

:::note
**Il controllo e' stato provato anche sul caso che deve fallire.**
Aggiungendo di proposito una pista fra `VSENS` e `GND`, il DRC esce con 3
violazioni (`shorting_items`, `clearance`, `tracks_crossing`) e codice 5.
Un controllo che non ha mai detto di no non ha dimostrato niente.
:::

## Accoppiamento col contenitore

`tools/check_fit.py` risponde a una domanda sola: la scheda, con i suoi
componenti, entra nel contenitore? Lo fa in due modi, perche' rispondono a
cose diverse.

**Ingombro**: confronto asse per asse fra il bounding box dello STL
esportato da KiCad e la cavita' interna che `case.scad` dichiara con
`echo("QUOTE ...")`. Dice di quanto eccede e in quale direzione.

**Collisione**: con il foro ottico della scheda allineato a quello del
contenitore, si **intersecano** i due solidi
(`enclosure/viste/accoppiamento.scad`). Un confronto fra numeri si ferma
all'involucro esterno e non vede ne' il divisorio fra i due vani ne' la
battuta del coperchio; l'intersezione li vede.

Nessuna quota e' scritta dentro il controllo: vengono dalle quote
dichiarate dal contenitore e dal `.kicad_pcb`. Un parametro che cambia da
una parte o dall'altra si propaga da solo.

### L'esito di oggi: non entra

```
scheda    50.00 x  34.00 x  15.00 mm   (componenti compresi)
cavita'   50.60 x  50.70 x   6.80 mm
ok   X: avanzano 0.60 mm in larghezza
ok   Y: avanzano 16.70 mm in profondita'
NO   Z: eccede di 8.20 mm in altezza
NO   la scheda compenetra il contenitore
```

La causa e' il **modulo innestato**. L'header femmina da 2,54 mm e' alto
8,5 mm, e con sopra il modulo porta l'assieme a 15 mm contro i 6,8 della
cavita'. Era previsto: la scelta del DIP con header e' stata fatta
sapendo che costava altezza, e il contenitore e' dimensionato sulla
millefori, dove la scheda e' alta 4 mm.

Quello che deve cambiare e' **il parametro `scheda` del contenitore**, non
il PCB — a meno che l'altezza sotto il coperchio della tramoggia non si
riveli il vincolo stringente, nel qual caso il criterio per cambiare idea
e' passare alle piazzole castellate, accettando che il modulo diventi
parte della scheda.

:::warning
**Il controllo non e' ancora un passo della CI**, e la ragione e' che oggi
direbbe di no: metterlo in pipeline adesso vorrebbe dire lasciare la CI
rossa. Va attivato nello stesso lavoro che aggiorna le quote del
contenitore, e fino ad allora va eseguito a mano.
:::

:::note
Anche questo controllo e' stato provato sui due casi che contano.
`tools/check_fit.py --scheda-finta 15x12x4` passa con codice 0;
`--scheda-finta 80x60x20` fallisce su tutti e tre gli assi. Fra l'altro,
un parallelepipedo 20 × 20 × 4 centrato sul foro ottico **non** passa: va
a sbattere sul divisorio fra i due vani, che il solo confronto degli
ingombri non avrebbe visto.
:::

## Cosa resta fuori, deliberatamente

- **Produzione.** Il repo fornisce il progetto, non le schede. I file
  Gerber non sono generati: i fabbricanti accettano il `.kicad_pcb`, e un
  pacchetto Gerber versionato sarebbe un secondo originale da tenere
  allineato.
- **Piano di massa.** Vedi sopra.
- **Serigrafia decorativa.** C'e' il minimo che serve a montare: i
  riferimenti, `B+`/`B-` e la legenda del ponticello.

<!-- Il percorso dello script e' relativo alla pagina, non alla radice:
     docmd riscrive href e src di link e immagini, ma non quelli dei tag
     <script>. -->
<script src="../../assets/js/stl-viewer.js"></script>
