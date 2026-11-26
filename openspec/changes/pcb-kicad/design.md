# Design

## Context

Lo schema e' verificato: ERC a zero, 7 reti controllate nodo per nodo. Il
PCB parte da li'.

Il footprint dello XIAO in uso e' quello **DIP**, scelto per la millefori.
Su PCB la scelta si riapre, e non e' scontata.

## Goals / Non-Goals

**Goals:**
- Il PCB non congela l'unica decisione hardware ancora aperta.
- Verificabile da riga di comando come il resto: DRC in CI.
- Render da piu' prospettive, dalla pipeline esistente.

**Non-Goals:**
- Ordinare o produrre schede.
- Miniaturizzare: lo spazio nel contenitore non e' il vincolo stringente,
  e un PCB piu' piccolo si salda peggio.

## Decisions

- **Lo schema resta la fonte di verita'.** Il PCB si allinea allo schema,
  mai il contrario: le modifiche alle reti si fanno sullo schema e si
  propagano.

- **MOSFET e collegamento diretto convivono.** Il motivo del rinvio era
  che il rame congela la scelta; il modo di ribaltare il rinvio senza
  riprendersi il problema e' prevedere entrambi. Il MOSFET e' montabile,
  e un ponticello permette il pilotaggio diretto da GPIO come oggi.
  **Attenzione: la logica di D2 si inverte fra le due configurazioni**,
  quindi la selezione non e' solo hardware: va riflessa nel firmware.

- **Footprint dello XIAO: da riconsiderare, non da ereditare.** Il DIP era
  una conseguenza della millefori. Su PCB le alternative hanno
  conseguenze diverse su altezza totale e rilavorabilita', e la scelta va
  motivata invece di trascinata.

- **DRC in CI come l'ERC**, con la stessa severita': un DRC che passa con
  warning non protegge niente, e il progetto ha gia' pagato il prezzo dei
  controlli indulgenti.

## Risks / Trade-offs

- **Il PCB puo' divergere dallo schema** senza che nessuno se ne accorga,
  se la verifica non lo controlla. Va verificata la corrispondenza, non
  solo la validita' del layout.

- **Il contenitore e' dimensionato sulla millefori.** Un PCB di forma
  diversa cambia i vani: i due modelli vanno tenuti coerenti, e i
  parametri del contenitore esistono apposta.

- **Nessuno ha ancora saldato il prototipo.** Il PCB viene disegnato prima
  che le misure sul banco dicano se il MOSFET serve. E' esattamente la
  situazione che il rinvio voleva evitare, ed e' il motivo per cui la
  doppia configurazione non e' un di piu' ma la condizione per procedere.

## Open Questions

- **Footprint dello XIAO sul PCB**: DIP con header, oppure castellato
  saldato a filo. Cambia altezza totale, possibilita' di recuperare il
  modulo e difficolta' di saldatura a mano.
