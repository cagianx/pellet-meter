---
title: "pellet-meter"
description: "Sensore di livello del pellet a batteria, BLE/BTHome verso Home Assistant."
---

# pellet-meter

Sensore di livello del pellet per stufe. Misura con un laser a tempo di volo
la distanza tra il coperchio e la superficie del pellet nella tramoggia, e la
manda a Home Assistant via **BLE advertising in formato BTHome v2**, insieme
allo stato della batteria.

Nessuna connessione BLE, nessun Wi-Fi, nessuna integrazione personalizzata: il
dispositivo si sveglia, misura, trasmette un pacchetto e torna a dormire. Home
Assistant lo riconosce da solo.

## Come e' fatto

| | |
|---|---|
| MCU | Seeed XIAO ESP32C6 — USB-C e caricabatterie LiPo integrati, BLE 5 |
| Sensore | VL53L1X (ToF laser, I²C) — misura da ~4 cm, niente zona cieca |
| Alimentazione | LiPo 3,7 V 1000 mAh con circuito di protezione |
| Radio | BLE advertising, BTHome v2 |

Con un risveglio ogni 15 minuti il consumo stimato e' di circa **1 mAh al
giorno**: oltre un anno di autonomia teorica, a quel punto conta piu'
l'autoscarica della batteria che il dispositivo.

## A che punto siamo

| | |
|---|---|
| Schema elettrico | fatto, ERC pulito e reti verificate |
| Contenitore 3D | da fare |
| Firmware | da fare |
| Configurazione Home Assistant | da fare |

Il repo fornisce **il progetto**, non la realizzazione: comprare, saldare,
stampare e installare sono attivita' di chi costruisce. Lo stato aggiornato e
i lavori aperti stanno in [Stato e lavori aperti](/stato/).

## Perche' questo sito esiste

Il lavoro su questo progetto e' distribuito su piu' sessioni che non
condividono memoria. Questo sito e' il posto dove si conserva il know-how:
non solo **cosa** e' stato fatto, ma **perche'**, cosa e' stato provato e non
funziona, e quali trappole sono gia' state pagate.

Se una cosa e' stata capita e non e' scritta qui, e' persa.
