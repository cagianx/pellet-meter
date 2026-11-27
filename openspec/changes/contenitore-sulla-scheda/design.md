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

- **Non si sceglie fra "piu' alto" e "piu' largo" a tavolino.** Cella
  accanto alla scheda da' ~70 x 54 x 19; cella sopra o sotto da' ~54 x 38
  ma oltre 25 mm di altezza. Quale sia preferibile lo decide lo spazio
  sotto il coperchio della tramoggia, che non conosciamo. Il modello
  espone la disposizione come **parametro**, cosi' la scelta si fa quando
  il numero arriva, senza riscrivere geometria.

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

## Open Questions

- **Quanto spazio c'e' sotto il coperchio della tramoggia?** E' il dato
  che decide la disposizione, e in ultima istanza se convenga tornare al
  modulo saldato a filo (castellato), che toglierebbe 8,5 mm.
