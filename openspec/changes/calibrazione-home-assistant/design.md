# Design

## Context

Vedi proposal.md. Il dispositivo e' scoperto in automatico dall'integrazione
BTHome; le entita' nascono da li'.

## Goals / Non-Goals

**Goals:**
- Configurazione copiabile e commentata, con i riferimenti in un posto solo.

**Non-Goals:**
- Integrazione custom: tutto deve funzionare con BTHome e i template standard.

## Decisions

- **Formula lineare come punto di partenza**, con interpolazione a tabella
  come alternativa gia' prevista: se il fondo del serbatoio e' a imbuto, il
  volume non e' lineare con la distanza.
- **Riferimenti come variabili in testa al template**, non sparsi nella
  formula: sono i due numeri che si toccano piu' spesso.

## Risks / Trade-offs

- La stima in kg al giorno dipende dalla densita' del pellet e dalla
  geometria: e' indicativa, non una misura.
- Il rilevamento della ricarica da salto di livello puo' confondersi con una
  lettura sporca: serve una soglia che tenga conto del rumore misurato.
