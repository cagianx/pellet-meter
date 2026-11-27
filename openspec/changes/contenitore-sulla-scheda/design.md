# Design

## Context

Vedi proposal.md. Il contenitore esiste ed e' verificato contro i propri
parametri; il PCB esiste ed e' verificato contro lo schema. Quello che
manca e' che i due siano verificati **l'uno contro l'altro**, ed e'
esattamente il controllo che oggi dice di no.

## Goals / Non-Goals

**Goals:**
- Il sensore guarda il pellet.
- La scheda vera entra, verificato automaticamente e in CI.
- Il contenitore resta attaccato al coperchio anche da aperto.

**Non-Goals:**
- Ridisegnare il PCB per far entrare il contenitore. Il PCB e' verificato
  contro lo schema; e' il contenitore che insegue l'hardware, non il
  contrario.
- Ottimizzare il volume. Finche' non sappiamo lo spazio disponibile,
  stringere e' indovinare.

## Decisions

- **L'ottica si sposta sul coperchio della scatola, e si incolla per il
  fondo.** Delle due vie possibili, questa tiene il pezzo incollato
  attaccato al coperchio della tramoggia: aprendo, resta su. L'alternativa
  — incollare il coperchio della scatola e lasciare che il corpo ci si
  agganci sotto — farebbe reggere tutto al pezzo removibile, e un'apertura
  accidentale farebbe cadere scheda e cella nel pellet.

  Conseguenza da non dimenticare: **il breakout va montato guardando il
  coperchio**, non il fondo. Cambia il verso del sensore sulla scheda, non
  solo un foro.

- **I vani si ridisegnano attorno a due soli oggetti**: la scheda
  assemblata e la cella. Il vano del breakout sparisce, perche' il
  breakout ora sta sulla scheda.

- **Le quote della scheda si leggono dal PCB, non si ribattono a mano.**
  Ribattere 50 x 34 x 15 in `case.scad` significa creare la terza copia di
  un numero che gia' esiste in due posti, e la prima che diventera' falsa.
  `check_fit.py` sa gia' ricavarle dal `.kicad_pcb`.

- **Il sensore sta contro la faccia incollata, e l'ottica e' un tunnel
  conico.** E' il vincolo che decide tutto il resto, ed e' arrivato con la
  misura della tramoggia: **50-70 mm** fra coperchio e pellet a pieno
  carico. Il VL53L1X misura da ~40 mm, quindi nel caso peggiore il sensore
  puo' stare al massimo **10 mm sotto il coperchio**.

  Il conto dice che il sensore **non puo' stare sul fondo** del
  contenitore, in nessuna delle due configurazioni:

  | Dove sta il sensore | Spessore | Misura a pieno carico |
  |---|---|---|
  | sul fondo, modulo innestato | 19 mm | 31 mm — **sotto il minimo** |
  | sul fondo, modulo castellato | 10,5 mm | 39,5 mm — **sotto il minimo** |
  | contro la faccia incollata | indifferente | ~46 mm — ok |

  Da qui tre conseguenze. La prima: **lo spessore del contenitore quasi
  non conta**, quindi la scelta fra modulo innestato e castellato non e'
  piu' in discussione — l'innestato resta. La seconda: la scheda va
  montata **alta**, contro la faccia incollata, e la cella sotto o
  accanto. La terza: fra sensore e pellet c'e' tutto lo spessore del
  contenitore, quindi l'apertura non e' piu' un foro nel fondo ma un
  **tunnel conico** che attraversa il pezzo, largo 5 mm all'ingresso e
  ~14 mm all'uscita con 19 mm di spessore.

- **La disposizione della cella resta un parametro**, ma non e' piu' la
  decisione critica: avendo stabilito che la scheda sta in alto, cella
  accanto o cella sotto cambiano l'ingombro, non la misura.

- **`check_fit.py` entra in CI solo quando passa.** Metterlo prima
  significherebbe una pipeline rossa per un difetto gia' noto e tracciato,
  e una pipeline che e' rossa di suo smette di dire qualcosa quando
  diventa rossa per un motivo nuovo.

## Risks / Trade-offs

- **Il margine in larghezza e' 0,60 mm**, cioe' nullo in pratica: basta
  una tolleranza di stampa a mangiarlo. Il ridisegno deve dare aria vera,
  non il minimo che fa passare il controllo.

- **Un contenitore piu' grande ha piu' leva sul biadesivo.** L'area di
  incollaggio cresce con la pianta, ma il momento cresce con lo sbalzo:
  `check_case.py` oggi verifica l'area, non il momento. Se il contenitore
  si allunga molto, quel controllo va rivisto.

- **Cambiare il verso del breakout tocca il PCB**, che e' gia' verificato:
  la modifica va fatta sullo schema o sul footprint, non aggiustando il
  layout a mano.

- **Fissaggio meccanico, non adesivo.** Due viti passanti con dado nel
  coperchio della tramoggia. Il biadesivo resta utile a tenere fermo il
  pezzo mentre si stringe, ma smette di essere l'elemento portante: su una
  lamiera che scalda, un adesivo non si strappa di colpo, **scivola**, e
  un dispositivo che scende di qualche millimetro falsa tutte le misure
  senza rompersi. Viti invece di rivetti perche' il dispositivo resta
  removibile senza trapano.

- **Una vite assicura anche il coperchio della scatola**, in aggiunta allo
  scatto e non al suo posto. Con l'ottica sul coperchio, quel coperchio
  guarda in giu': se lo scatto cede, scheda e cella cadono nel pellet.
  Lo scatto da solo era difendibile quando il coperchio guardava in su.

- **L'altezza del modulo sopra la scheda e' un parametro.** Zoccolo
  standard, zoccolo basso o modulo saldato a filo cambiano lo spessore
  della scatola di quasi 7 mm. Siccome il PCB porta un footprint che
  accetta entrambe le soluzioni, la scelta appartiene a chi costruisce, e
  il contenitore deve seguirla senza essere riscritto.

## Open Questions

Nessuna. Lo spazio sotto il coperchio e' stato misurato: 50-70 mm a pieno
carico.

Resta un **margine stretto** da tenere d'occhio: con il sensore in alto la
misura a pieno carico e' ~46 mm contro un minimo di ~40. Sei millimetri.
Se la tramoggia viene riempita oltre il colmo, il sensore finisce sotto il
minimo e smette di dare letture valide. Non e' un difetto da correggere
nel contenitore — e' il motivo per cui il firmware deve avere un
comportamento definito quando nessuna lettura e' valida, che e' gia' il
task 3.3 di `firmware-bthome`, e per cui Home Assistant deve accorgersi
del dato fermo.
