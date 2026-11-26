---
title: "Trappole di KiCad 10"
description: "Errori del formato file pagati sul campo, con la diagnosi."
---

# Trappole di KiCad 10

Servono a chi genera o manipola file KiCad via script. Sono state pagate
tutte, una per una.

:::danger
**KiCad, davanti a un file malformato, dice solo `Fallito caricamento
schema`.** Nessuna riga, nessuna colonna, nessun motivo. Non esiste un
messaggio piu' verboso: `sch erc`, `sch upgrade` e `sch export` danno tutti
la stessa frase. L'unico metodo che funziona e' il **bisect**: partire da un
file minimo che carica e aggiungere un pezzo alla volta.
:::

## Versioni del formato

| File | Versione | `generator_version` |
|---|---|---|
| `.kicad_sch` | `20260306` | `"10.0"` |
| `.kicad_sym` | `20251024` | `"10.0"` |

Un file dichiarato come KiCad 9 (`20250114`) **non accetta i simboli delle
librerie di sistema**, che sono in formato 10 e contengono token che il
parser della versione 9 non conosce.

Per scoprire la versione corrente senza indovinare: prendere un template di
sistema e aggiornarlo, poi leggere l'intestazione.

```bash
cp /usr/share/kicad/template/Arduino_Uno/Arduino_Uno.kicad_sch ref.kicad_sch
kicad-cli sch upgrade --force ref.kicad_sch
head -4 ref.kicad_sch
```

Questo e' anche il modo migliore per ottenere un **file di riferimento
autentico** con `lib_symbols` popolato, da confrontare con quello che si sta
generando.

## Nei `lib_symbols` solo il padre prende il prefisso

Dentro il blocco `(lib_symbols)` di uno schema, il simbolo principale si
chiama `Libreria:Nome`, ma **le sotto-unita' mantengono il nome originale**:

```
(symbol "Connector_Generic:Conn_01x06"   ← prefissato
    ...
    (symbol "Conn_01x06_0_1"             ← NON prefissato
    (symbol "Conn_01x06_1_1"             ← NON prefissato
```

Rinominare anche le sotto-unita' in `Libreria:Nome_0_1` fa fallire il
caricamento. Questo e' costato un bisect completo.

## I ritorni a capo vanno scritti come escape

Nelle stringhe quotate, un newline vero fa fallire il caricamento. Le note
multi-riga vogliono la sequenza `\n` di due caratteri.

## L'asse Y e' invertito tra libreria e schema

La posizione di un pin nello schema e':

```
x_schema = X_istanza + px
y_schema = Y_istanza − py      ← segno meno
```

dove `px`/`py` sono le coordinate del pin nella libreria.

## La griglia e' ancorata a zero

Le coordinate devono essere **multipli di 1,27 mm**. Mettere un componente a
`100 mm` sembra innocuo ma 100 non e' multiplo di 1,27: l'ERC segnala
`endpoint_off_grid` su ogni pin e ogni filo.

## I simboli derivati non ripetono i pin

Un simbolo come `DMG2301L` usa `(extends "TP0610T")` e **non contiene nessun
pin**: li eredita dal genitore.

:::danger
Chi legge la libreria deve seguire `extends`. Altrimenti ottiene zero pin e
genera uno schema **senza quei collegamenti, in silenzio**: nessun errore,
nessun avviso, solo un componente scollegato che si scopre al momento di
saldare.
:::

**Non esiste un `Device:Q_PMOS_GSD` di comodo.** In KiCad 10 la libreria
`Device` ha solo `Q_PMOS`, e i suoi pin sono numerati `D`, `G`, `S`: lettere,
non numeri, quindi non si abbinano a nessun footprint SOT-23. La via che
funziona e' copiare nella libreria di progetto il simbolo **padre** di quello
che serve — per `DMG2301L` e' `Transistor_FET:TP0610T`, con pin 1=G, 2=S,
3=D — rinominarlo e aggiornarne Valore, Datasheet e Descrizione. Cosi' il
simbolo e' autonomo e dentro lo schema non c'e' nessun `extends` da gestire.

## Le librerie si referenziano con variabili

Nelle tabelle di progetto `sym-lib-table` e `fp-lib-table`:

- `${KICAD10_SYMBOL_DIR}` e `${KICAD10_FOOTPRINT_DIR}` per le librerie di sistema
- `${KIPRJMOD}` per quelle di progetto

Funzionano sia in locale sia dentro il container della CI, al contrario dei
percorsi assoluti.

## Lo XIAO ESP32C6 non e' nelle librerie standard

Simbolo e footprint vengono dalla
[libreria OPL di Seeed](https://github.com/Seeed-Studio/OPL_Kicad_Library).
Nel repo c'e' solo il simbolo `XIAO-ESP32-C6-SMD` ma **esiste anche il
footprint DIP** (`XIAO-ESP32-C6-DIP.kicad_mod`): il simbolo e' lo stesso, si
abbina al footprint che serve.

## Le `property private` dei simboli di sistema vanno copiate

Portando un simbolo di sistema dentro i `lib_symbols` dello schema, viene la
tentazione di togliere le `(property private "KLC_S5.1" ...)`: sono note di
lint delle librerie ufficiali e non servono a niente qui dentro.

Toglierle fa scattare `lib_symbol_mismatch`, che e' un **warning** e quindi
fa fallire la CI, perche' KiCad confronta la copia dentro lo schema con
quella della libreria e le `private` fanno parte del confronto. Si copiano
verbatim.

## `re.sub` interpreta gli escape anche nella stringa di sostituzione

Non e' una trappola di KiCad ma la si incontra solo qui, e costa un
pomeriggio. Le note di testo dello schema contengono `\n` come **escape
letterale**, due caratteri. Riscriverne una con

```python
re.sub(r'\(text "[^"]*"', '(text "%s"' % nota, blocco)
```

inserisce ritorni a capo **veri** dentro una stringa quotata, perche' la
stringa di sostituzione passa anch'essa per l'interprete degli escape. KiCad
poi dice solo `Fallito caricamento schema`, senza riga ne' motivo. La
sostituzione va fatta con una lambda:

```python
re.sub(r'\(text "[^"]*"', lambda _: '(text "%s"' % nota, blocco)
```

## Trappole del PCB

### `FootprintLoad` non mette il nome della libreria

Con `pcbnew.FootprintLoad(percorso, nome)` il footprint arriva col FPID
senza prefisso di libreria. La parita' con lo schema confronta il FPID
**completo**, quindi segnala `footprint_symbol_mismatch` su ogni componente.
Si rimedia con `fp.SetFPIDAsString("Libreria:Nome")`.

### Le reti del PCB si chiamano come quelle della netlist, barra compresa

Nella netlist esportata le reti sono `/VBAT`, non `VBAT`, e i pin scollegati
hanno reti vere con nomi tipo `unconnected-(U1-D1-Pad2)`. Creando sul PCB
delle reti chiamate `VBAT`, la parita' segnala `net_conflict` su **ogni**
piazzola; saltando le `unconnected-`, segnala che alla piazzola "manca il
collegamento dato dallo schema". I nomi si prendono dalla netlist cosi' come
sono.

### `--schematic-parity` pretende una piazzola per ogni pin del simbolo

Anche per i pin non collegati. Un simbolo che dichiara 24 pin e un footprint
che ne ha 14 producono dieci segnalazioni `net_conflict` del tipo "Nessuna
piazzola trovata per il pin 18". Non e' un capriccio: e' il modo in cui si
accorge che footprint e simbolo descrivono due cose diverse. Per lo XIAO la
soluzione e' stata aggiungere al footprint le dieci piazzole di servizio,
vedi [Circuito stampato](/hardware/pcb/).

### `attr smd` su un footprint con fori passanti

Il footprint DIP dello XIAO arriva dalla libreria Seeed dichiarato
`(attr smd)` pur avendo piazzole passanti. Il DRC lo chiama
`footprint_type_mismatch` ed e' un **errore**. Va messo `(attr through_hole)`.

### Il render ignora i modelli 3D in STL

`kicad-cli pcb render` carica i `.wrl` e **salta i `.stl` senza dire
niente**: il render esce con il componente mancante e il comando riesce. Il
modello sostitutivo dello XIAO e' quindi in VRML.

Attenzione all'unita': KiCad legge il VRML in unita' da **0,1 pollice**. Il
modo di non impazzire e' avvolgere tutto in un
`Transform { scale 0.39370079 ... }` e scrivere i numeri in millimetri.

E `DEF` in VRML **definisce e disegna**: una forma definita al primo livello
compare anche nell'origine, oltre che dove la si riusa con `USE`. Va messa
gia' dentro la sua `Transform`.
