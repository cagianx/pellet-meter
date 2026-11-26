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

## Open Questions

- **Framework**: ESP-IDF da' controllo diretto sul pacchetto e sui consumi;
  Arduino e' piu' rapido ma con BTHome e deep sleep richiede piu' lavoro, e
  ESPHome richiederebbe un componente esterno. Da decidere prima di iniziare.
- **Intervallo di risveglio**: proposta iniziale 10 minuti, da confermare dopo
  la misura dei consumi reali.
- **Device info `0x40` o `0x44`**: il secondo dichiara un dispositivo
  trigger-based che dorme. Da verificare come Home Assistant gestisce la
  disponibilita' nei due casi.

## Risks / Trade-offs

- Il consumo dichiarato dello XIAO in deep sleep e' da verificare sul campo:
  e' la variabile che decide l'autonomia.
- Alimentare il sensore dal GPIO e' al limite della corrente erogabile: se le
  misure mostrano cali di tensione, lo schema prevede gia' l'upgrade a MOSFET.
