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
- **L'SVG arriva nel sito da un job dedicato dello stesso workflow `docs`.**
  Delle tre strade possibili — committarlo, farlo produrre al workflow docs,
  passarlo tra i due workflow — vince la seconda in una variante che evita
  il suo difetto: un job `render` nel container KiCad produce le immagini e
  le passa al job `build` come artefatto *dello stesso workflow*, che e' un
  meccanismo nativo. Niente file generati versionati, e niente artefatti da
  rincorrere tra workflow diversi, che e' la parte fragile.
- **Un solo script, `tools/render.sh`**, usato identico in locale e in CI:
  due definizioni di "come si fa un render" divergono il giorno dopo.
- **Il README usa il PNG, il sito l'SVG.** Su GitHub le immagini passano da
  un proxy e il README non puo' usare percorsi relativi a file non
  versionati: punta all'URL del PNG pubblicato su Pages. Il PNG e' anche la
  forma che non puo' non renderizzare.
- **Il ritaglio si misura sui pixel, non sulle coordinate dell'SVG.**
  Il disegno occupa il 24% di un A3, quindi l'inquadratura va stretta sul
  contenuto; il bounding box viene da ImageMagick sul PNG e viene riportato
  sul `viewBox`. Interpretare i path dell'SVG significherebbe ricostruire
  archi e trasformazioni, cioe' sbagliare in silenzio.

## Open Questions

Nessuna.

## Risks / Trade-offs

- La verifica automatica copre la connettivita', non la leggibilita': che lo
  schema sia diventato davvero piu' chiaro puo' dirlo solo chi lo guarda.
