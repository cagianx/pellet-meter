# pellet-meter

Sensore di livello del pellet a batteria, per stufe. Misura con un sensore ToF
laser la distanza tra il coperchio e la superficie del pellet nella tramoggia,
e la trasmette a Home Assistant via **BLE advertising in formato BTHome v2**,
insieme allo stato della batteria.

Nessuna connessione BLE, nessun Wi-Fi, nessuna integrazione custom: il
dispositivo si risveglia, misura, trasmette un pacchetto di advertising e
torna in deep sleep. Home Assistant lo riconosce da solo.

![Schema elettrico del pellet-meter](https://cagianx.github.io/pellet-meter/assets/render/schema.png)

## Hardware

| | |
|---|---|
| MCU | Seeed XIAO ESP32C6 — USB-C e caricabatterie LiPo integrati, BLE 5 |
| Sensore | VL53L1X (ToF laser, I²C) — misura da ~4 cm, niente zona cieca |
| Alimentazione | LiPo 3,7 V 1000 mAh con circuito di protezione |
| Radio | BLE advertising, BTHome v2 |

Consumo stimato con risveglio ogni 15 minuti: **~1 mAh al giorno**, cioe'
oltre un anno di autonomia teorica — a quel punto conta piu' l'autoscarica
della batteria che il dispositivo.

## Stato

| | |
|---|---|
| Schema elettrico | fatto — ERC pulito, netlist verificata |
| Contenitore 3D | da fare |
| Firmware | da fare |
| Configurazione Home Assistant | da fare |

Il repo fornisce **il progetto**, non la realizzazione: schema, firmware,
modello del contenitore e configurazione di Home Assistant. Comprare,
saldare, stampare e installare sono attivita' di chi costruisce.

La calibrazione (distanza ↔ percentuale di riempimento) si fa **in Home
Assistant**, non nel firmware: ricalibrare non richiede un reflash.

## Documentazione

Il sito completo — decisioni di progetto, hardware, collegamenti, formato del
pacchetto BTHome, configurazione di Home Assistant — e' pubblicato qui:

**https://cagianx.github.io/pellet-meter/**

Per lavorare sul repo, vedi [CLAUDE.md](CLAUDE.md): contiene i comandi di
verifica e le trappole del formato KiCad incontrate durante lo sviluppo.

## Struttura

```
kicad/        progetto KiCad 10 (schema, librerie di progetto, strumenti)
enclosure/    contenitore parametrico OpenSCAD
docs/         sorgenti del sito di documentazione
```
