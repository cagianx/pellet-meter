# Design

## Context

Vedi proposal.md. Lo schema e' gia' fissato: sensore alimentato da D2, I2C su
D4/D5, XSHUT su D3, partitore su D0.

## Goals / Non-Goals

**Goals:**
- Consumo in deep sleep nell'ordine delle decine di µA.
- Pacchetto riconosciuto da Home Assistant senza integrazioni custom.

**Non-Goals:**
- Cifratura BTHome: opzionale, si valuta dopo.
- OTA: il dispositivo e' raggiungibile via USB-C.

## Decisions

- **Niente calibrazione nel firmware**: la conversione distanza → percentuale
  cambia col serbatoio e con la forma del fondo; metterla nel firmware
  significherebbe riflashare per ogni aggiustamento.
- **Packet id in RTC memory**: e' l'unica memoria che sopravvive al deep sleep
  senza usurare la flash.
- **Framework: ESP-IDF 5.x con NimBLE.** ESPHome era escluso in partenza
  (componente esterno per BTHome in trasmissione, e calibrazione di fatto nel
  dispositivo). Tra ESP-IDF e Arduino decide il consumo, che e' l'obiettivo
  del progetto: ESP-IDF non mette strati tra il codice e le tre cose che
  decidono l'autonomia — sequenza di deep sleep, stato dei GPIO prima di
  dormire, switch RF dell'antenna. Il costo e' il driver del sensore, che si
  parte dall'API ULD di ST (C portabile, serve solo il layer di piattaforma
  per l'I²C) invece di una libreria Arduino pronta.
- **Device info `0x44`, trigger-based.** In Home Assistant
  `BTHomeSensor.available` ritorna `True` quando il dispositivo e' *sleepy*,
  e `sleepy_device` e' esattamente il bit 2 del device info, salvato nella
  config entry (quindi sopravvive al riavvio). Con `0x40` la disponibilita'
  dipende dall'intervallo di advertising imparato da `habluetooth`: un solo
  pacchetto perso fa sparire il dispositivo. Il rovescio: con `0x44` non va
  mai in `unavailable`, quindi un dispositivo morto non si distingue da uno
  vivo — la vitalita' va controllata sull'eta' del dato, requisito che ricade
  su `calibrazione-home-assistant`.
- **Risveglio ogni 10 minuti.** Il livello cambia lentamente (stufa ~1 kg/h,
  tramoggia 15–20 kg): 10 minuti sono gia' molto piu' del necessario per il
  livello, e la granularita' serve al rilevamento della ricarica. Inoltre
  600 s stanno sotto i 900 s di
  `FALLBACK_MAXIMUM_STALE_ADVERTISEMENT_SECONDS`. Criterio per cambiare: si
  allunga a 15 o 30 minuti se il consumo misurato mette in pericolo l'anno di
  autonomia; si accorcia solo se il rilevamento della ricarica perde eventi.

## Open Questions

- **Cifratura BTHome con bindkey**: opzionale, si valuta dopo.

## Risks / Trade-offs

- Il consumo dichiarato dello XIAO in deep sleep e' da verificare sul campo:
  e' la variabile che decide l'autonomia.
- Alimentare il sensore dal GPIO e' al limite della corrente erogabile: se le
  misure mostrano cali di tensione, lo schema prevede gia' l'upgrade a MOSFET.
