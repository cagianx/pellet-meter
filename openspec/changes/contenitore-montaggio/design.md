# Design

## Context

Il modello attuale e' in `enclosure/case.scad`: scatola e coperchio, labbro
ad anello che entra in una battuta. Montaggio e protezione non erano ancora
decisi, ora si'.

## Goals / Non-Goals

**Goals:**
- Stampabile senza supporti, come il resto.
- Il tappo non si perde: resta legato al contenitore.
- La chiusura si apre con le mani, senza attrezzi, ma non da sola.

**Non-Goals:**
- Tenuta stagna. Serve a tenere fuori la polvere, non l'acqua.
- Viti o inserti filettati: aggiungono ferramenta a un pezzo che deve
  restare semplice da stampare e da iterare.

## Decisions

- **Tappo con cordino stampato**, non un pezzo separato. Un tappo libero
  in una tramoggia e' un tappo perso al primo smontaggio. Il cordino e' un
  filetto sottile stampato nello stesso pezzo, che fa da cerniera viva.

- **Chiusura a scatto, non a vite.** Si apre facendo leva con un'unghia
  in una tacca, e tiene a testa in giu'. Le viti richiederebbero inserti
  o filetti stampati, che su un pezzo da iterare si rompono prima del
  resto.

  Il verso e' **l'opposto di come era stato scritto qui**: i dentini
  stanno sulla battuta della scatola e le finestre nel labbro del
  coperchio, non viceversa. In quei millimetri la battuta riduce la
  parete a 0,9 mm: un incavo profondo quanto serve al dentino ne
  lascerebbe 0,3, cioe' una parete di un'estrusione. Una finestra nel
  labbro invece passa da parte a parte e non lascia spessori sottili, e
  il dentino cresce sulla parete dove di materiale ce n'e'.

- **La superficie di incollaggio e' il fondo**, cioe' la faccia che oggi
  guarda il pellet. Il contenitore si monta **capovolto** rispetto a come
  e' disegnato: il fondo diventa il lato incollato al coperchio della
  tramoggia, e il foro ottico guarda in basso attraverso il coperchio
  stesso. Va detto esplicitamente perche' e' controintuitivo leggendo il
  modello.

- **Area di incollaggio come parametro verificato**, non come conseguenza
  della forma. Il biadesivo ha una portata per unita' di superficie: se il
  contenitore cresce, l'area deve crescere con lui. `check_case.py`
  controlla che l'area disponibile stia sopra un minimo dichiarato.

- **Il peso stimato e' un parametro.** Serve a rendere verificabile la
  tenuta dell'incollaggio: senza un numero, "abbastanza biadesivo" non
  vuol dire niente.

## Risks / Trade-offs

- **La cerniera viva si rompe a flessioni ripetute**, soprattutto in PLA.
  Accettabile: il tappo si apre di rado, e il pezzo si ristampa. In PETG
  dura di piu'.

- **I dentini a scatto dipendono dalla tolleranza di stampa** piu' del
  resto della geometria. Sono legati al parametro `gioco` esistente, cosi'
  resta un numero solo da tarare.

- **Il calore**: il coperchio di una tramoggia puo' scaldarsi. Il PLA cede
  sopra i ~60 °C e il biadesivo perde presa. E' un limite del materiale,
  non del modello, e va scritto in docs/ accanto alla scelta del
  materiale.

## Open Questions

Nessuna.
