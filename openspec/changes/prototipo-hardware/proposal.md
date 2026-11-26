# Proposal

## Why

Lo schema e' verificato sulla carta, ma nessuno ha ancora acceso niente. Fra
lo schema corretto e il dispositivo montato ci sono tre passaggi che non sono
tracciati da nessuna parte: comprare i componenti, verificare su breadboard
che il VL53L1X legga davvero il pellet in quelle condizioni, e saldare su
millefori.

Il secondo e' il piu' importante: e' la prova che l'intero progetto sta in
piedi. Se il sensore non legge in modo stabile dentro la tramoggia — per
polvere, riflessi o coperchio chiuso — cambia il sensore, e con esso schema,
firmware e contenitore.

## What Changes

- Ordine dei componenti e verifica di quanto arriva.
- Montaggio su breadboard e prima lettura del VL53L1X.
- **Prova sul pellet reale**, nella tramoggia, a coperchio chiuso.
- Conferma o smentita della scelta del sensore, con l'RCWL-1601 come
  confronto se serve.
- Saldatura del circuito su millefori.

## Capabilities

### New Capabilities
- `prototipo`: realizzazione fisica e validazione sul campo del circuito.

## Impact

Se la prova sul pellet reale va male, ne risentono tutti gli altri change:
`firmware-bthome` per il driver del sensore, `contenitore-3d` per gli
ingombri, `calibrazione-home-assistant` per il campo di misura. Per questo
viene prima.
