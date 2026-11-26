# Proposal

## Why

Lo schema e' verificato ma il dispositivo non fa ancora nulla: serve il
firmware che misura, trasmette e torna a dormire. E' il pezzo che decide
l'autonomia, obiettivo oltre un anno con una LiPo da 1000 mAh.

## What Changes

- Ciclo deep sleep → misura → advertising BTHome v2 → deep sleep.
- Lettura VL53L1X su I2C, mediana di 5-7 misure scartando le letture non valide.
- Lettura della batteria da ADC calibrato sul partitore, con stima della percentuale.
- Pacchetto BTHome v2 non cifrato, oggetti in ordine crescente di ID.
- Packet id in RTC memory, cosi' Home Assistant scarta i duplicati.
- Gestione dello switch RF dell'antenna a ogni risveglio.

## Capabilities

### New Capabilities
- `misura-livello`: acquisizione della distanza e della tensione di batteria.
- `trasmissione-bthome`: formato del pacchetto e comportamento radio.

## Impact

Nuova cartella `firmware/`. Da decidere il framework (ESP-IDF o Arduino): e'
una decisione aperta, vedi design.md.
