# Proposal

## Why

Il dispositivo trasmette millimetri, ma quello che serve e' sapere quanto
pellet resta e quando ricaricare. La conversione sta in Home Assistant, cosi'
si ricalibra senza riflashare.

## What Changes

- Template che converte la distanza in percentuale di riempimento.
- Avviso sotto una soglia configurabile.
- Rilevamento della ricarica da un salto improvviso del livello.
- Stima del consumo in kg al giorno e dell'autonomia residua.

## Capabilities

### New Capabilities
- `calibrazione-livello`: conversione da distanza misurata a livello e
  grandezze derivate.

## Impact

Nuova cartella `homeassistant/` con la configurazione da copiare. Nessun
impatto sul firmware.
