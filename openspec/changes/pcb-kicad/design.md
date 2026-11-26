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

- **Footprint dello XIAO: DIP con header femmina, cioe' modulo
  innestato.** L'alternativa erano le piazzole castellate, saldate a filo
  della scheda.

  Le castellate vincono sull'altezza: il modulo appoggia a ~1 mm dal rame
  invece dei ~5-6 mm che impone un header. Su un contenitore alto 10,8 mm
  non e' poco.

  Vince comunque il DIP, per due ragioni che pesano di piu'. La prima e'
  che **il modulo e' il componente piu' caro della distinta**, e innestato
  si recupera: se si brucia, se si vuole provare un altro XIAO, se il
  progetto cambia, si sfila. Saldato a filo e' definitivo. La seconda e'
  che **le castellate si saldano a mano molto peggio**: sono quattordici
  piazzole sul bordo, e chi costruisce non e' detto che faccia
  elettronica tutti i giorni. Un progetto che si puo' montare male e' un
  progetto che resta nel cassetto.

  **Il criterio per cambiare idea**: se l'altezza totale diventa il
  vincolo — tipicamente perche' sotto il coperchio della tramoggia non
  c'e' abbastanza spazio — si passa alle castellate, accettando che il
  modulo diventi parte della scheda.

- **La selezione MOSFET / diretto e' un ponticello a saldare a tre
  piazzole**, non un jumper con pettine. Un pettine aggiunge un
  componente, dell'altezza e un contatto che puo' allentarsi per vibrazione
  in una stufa; un ponticello e' rame e una goccia di stagno.

  **Default: collegamento diretto**, cioe' il comportamento di oggi, con
  il MOSFET non montato. Chi costruisce parte dalla configurazione
  verificata, e passa all'altra solo se le misure lo richiedono.

  **La logica di D2 si inverte** fra le due configurazioni. Perche' questo
  non diventi un guasto da diagnosticare col multimetro, il firmware deve
  esporre la configurazione come scelta esplicita a compile time, con il
  default allineato al default del rame: non deve essere possibile
  montare il MOSFET e dimenticarsene.

- **I modelli 3D mancanti si sostituiscono dichiarandolo, non si
  ignorano.** Per lo XIAO si usa il modello di un altro della famiglia:
  condividono i 21 x 17,5 mm, quindi come solido per la verifica di
  accoppiamento e' fedele, e la differenza e' la serigrafia. Per il
  breakout VL53L1X, che oggi e' solo un header a 6 pin, il corpo si
  aggiunge **dal lato OpenSCAD** come parallelepipedo parametrico: evita
  di dover produrre un file STEP a mano, e tiene l'ingombro dove stanno
  gia' gli altri parametri del contenitore.

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

Nessuna di elettronica. Resta un dato **fisico** che solo chi installa
puo' fornire: **quanto spazio c'e' sotto il coperchio della tramoggia**.
E' il numero che decide se l'altezza del modulo innestato e' accettabile
o se servono le castellate. Finche' manca, il progetto procede con il
DIP e il criterio per cambiare idea scritto sopra.
