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

Nel dubbio, si puo' usare il simbolo generico (`Q_PMOS_GSD`, con G=1 S=2 D=3)
e mettere la sigla reale nel campo Valore.

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
