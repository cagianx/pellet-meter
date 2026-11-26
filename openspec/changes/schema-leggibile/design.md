# Design

## Context

Vedi proposal.md. Lo schema e' nato da `kicad/tools/gen_schematic.py`, che
collega le reti per etichetta invece che con fili lunghi: scelta fatta per
tenere banale la geometria generata, non per leggibilita'.

## Goals / Non-Goals

**Goals:**
- Schema leggibile da chi salda, senza consultare la netlist.
- Schema visibile nel sito senza scaricare nulla.

**Non-Goals:**
- Riscrivere il generatore perche' produca una bella disposizione: il
  posizionamento estetico e' lavoro da GUI, automatizzarlo costa piu' di
  quanto renda per uno schema di otto componenti.
- Passare da etichette a fili lunghi: le etichette restano, sono leggibili e
  l'ERC le verifica.

## Decisions

- **Modifica nella GUI, non nel generatore.** Da quel momento il
  `.kicad_sch` e' l'unica fonte di verita'. Il generatore resta nel repo
  come documentazione di come lo schema e' nato, con l'avvertenza di non
  rieseguirlo sopra.
- **Pubblicazione via SVG**, non PNG: e' gia' esportato dalla CI, scala senza
  sgranare e pesa poco.

## Open Questions

- **Come arriva l'SVG nel sito**: committarlo in `docs/` accettando un file
  generato nel repo, oppure farlo produrre al workflow docs installando
  KiCad, oppure far passare l'artefatto tra i due workflow. La prima e' la
  piu' semplice e la meno fragile, ma contraddice la regola di non versionare
  le uscite generate. Da decidere.

## Risks / Trade-offs

- Dopo la modifica a mano, rieseguire il generatore distrugge il lavoro.
  L'avvertenza e' gia' in CLAUDE.md e in testa allo script, ma resta un
  rischio reale.
