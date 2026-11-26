# Design

## Context

Vedi proposal.md. Lo schema era stato generato via script, e lo script
collegava le reti **per etichetta** invece che con fili lunghi: scelta fatta
per tenere banale la geometria generata, non per leggibilita'. Lo script e'
stato eliminato una volta esaurito il suo compito; `pellet-meter.kicad_sch`
e' l'unica fonte di verita'.

## Goals / Non-Goals

**Goals:**
- Schema leggibile da chi salda, senza dover consultare la netlist.
- Schema visibile nel sito senza scaricare artefatti.

**Non-Goals:**
- Automatizzare la disposizione: il posizionamento estetico e' lavoro da GUI,
  e per otto componenti automatizzarlo costa piu' di quanto renda.
- Passare da etichette a fili lunghi: le etichette restano, sono leggibili e
  l'ERC le verifica.

## Decisions

- **Pubblicazione via SVG**, non PNG: e' gia' prodotto dalla CI, scala senza
  sgranare e pesa poco.

## Open Questions

- **Come arriva l'SVG nel sito**: committarlo in `docs/` accettando un file
  generato dentro al repo, farlo produrre al workflow docs installando KiCad,
  oppure far passare l'artefatto tra i due workflow. La prima e' la piu'
  semplice e la meno fragile, ma contraddice la regola di non versionare le
  uscite generate. Da decidere.

## Risks / Trade-offs

- La verifica automatica copre la connettivita', non la leggibilita': che lo
  schema sia diventato davvero piu' chiaro puo' dirlo solo chi lo guarda.
