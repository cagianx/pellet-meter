# Design

## Context

Vedi proposal.md. Lo schema e la distinta sono gia' pronti: la distinta la
genera la CI dallo schema, come artefatto.

## Goals / Non-Goals

**Goals:**
- Sapere presto se il sensore scelto regge le condizioni reali.
- Arrivare a un circuito saldato e affidabile.

**Non-Goals:**
- PCB: deliberatamente rimandato finche' il prototipo non conferma le scelte.
- Firmware completo: qui basta il minimo per leggere il sensore.

## Decisions

- **La prova sul pellet reale viene prima del firmware completo.** Serve solo
  uno sketch che legga la distanza e la stampi: se il sensore non va, tutto
  il lavoro sul deep sleep e su BTHome sarebbe da rifare.
- **RCWL-1601 come confronto, non come alternativa predefinita.** Si compra
  gia' adesso perche' costa poco e serve solo se il ToF delude: ordinarlo
  dopo significherebbe fermarsi una settimana.

## Risks / Trade-offs

- La polvere sulla finestra ottica e' il rischio piu' concreto per un ToF in
  una tramoggia: va provato con la stufa che ha gia' lavorato, non appena
  pulita.
- Le letture su superficie a cono possono variare molto a seconda di dove
  punta il fascio: e' il motivo della ROI ristretta e della mediana.
