# Proposal

## Why

L'elettronica e la batteria devono stare **fuori** dal serbatoio, mentre il
sensore deve guardare in basso dal coperchio. Senza un contenitore il
prototipo non e' installabile sulla stufa, e la LiPo non va tenuta vicino a
superfici calde.

## What Changes

- Contenitore parametrico in OpenSCAD per XIAO ESP32C6 + LiPo 603048 + breakout VL53L1X.
- Apertura per la finestra ottica del sensore, rivolta verso il basso.
- Accesso alla USB-C per la ricarica senza smontare nulla.
- Fissaggio al coperchio che non tocchi coclea ne' microinterruttore di sicurezza.
- STL generati dalla CI e pubblicati come artefatti.

## Capabilities

### New Capabilities
- `contenitore`: forma, aperture e vincoli meccanici dell'involucro stampato in 3D.

## Impact

Nuova cartella `enclosure/`. Il job `contenitore` della CI, oggi inattivo,
inizia a produrre STL.
