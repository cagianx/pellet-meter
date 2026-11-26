---
title: "Schema elettrico"
description: "Il progetto KiCad, come e' fatto e come si verifica."
---

# Schema elettrico

Progetto **KiCad 10** in `kicad/`. Il file `pellet-meter.kicad_sch` e' la
fonte di verita'.

Il PDF, l'SVG e la distinta componenti sono prodotti dalla CI a ogni
modifica, come artefatto **`schema`** del workflow `hardware`
([ultimi run](https://github.com/cagianx/pellet-meter/actions)).

## Componenti

| Rif | Valore | Note |
|---|---|---|
| U1 | XIAO-ESP32-C6 | Footprint DIP, per header su millefori |
| U2 | VL53L1X | Breakout su header a 6 pin |
| BT1 | LiPo 3,7 V 1000 mAh | |
| R1, R2 | 1 MΩ | Partitore della batteria |
| C1 | 100 nF | Stabilizza il nodo ADC |
| C2 | 10 µF | Bulk sull'alimentazione del sensore |
| C3 | 100 nF | Disaccoppiamento del sensore |

## Librerie di progetto

Il simbolo e il footprint dello XIAO ESP32C6 **non sono nelle librerie
standard di KiCad**: vengono dalla
[libreria OPL di Seeed](https://github.com/Seeed-Studio/OPL_Kicad_Library)
e sono copiati in `kicad/lib/`. Viene usato il footprint **DIP** (fori
passanti), non quello SMD castellato, perche' il montaggio e' su millefori.

Il simbolo del breakout VL53L1X e' scritto a mano: nelle librerie standard
c'e' solo il chip nudo (`VL53L1CXV0FY1`), che non corrisponde a una scheda
breakout con header.

## Lo schema e' corretto ma graficamente sbilanciato

Va detto: i componenti sono ammassati in alto a sinistra con meta' foglio A3
vuoto. E' stato generato via script per poter verificare le reti da riga di
comando, e la disposizione non e' stata curata. Elettricamente e' verificato;
esteticamente va sistemato a mano nella GUI.

## Come si verifica

Vedi [Come si verifica](/know-how/verifica/): l'ERC pulito **non basta**.
