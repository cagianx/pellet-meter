# Tasks

## 1. Decisioni da chiudere prima

- [ ] 1.1 Scegliere il footprint dello XIAO sul PCB, motivando in docs/ l'effetto su altezza, recuperabilita' e saldatura
- [ ] 1.2 Definire come si seleziona fra MOSFET e pilotaggio diretto, e cosa comporta per il firmware

## 2. Layout

- [ ] 2.1 Assegnare i footprint e importare la netlist dallo schema
- [ ] 2.2 Contorno scheda compatibile con i vani del contenitore
- [ ] 2.3 Piazzamento e sbroglio, con il partitore vicino al pin ADC
- [ ] 2.4 Interruttore a P-MOSFET con ponticello di esclusione

## 3. Verifica

- [ ] 3.1 DRC senza violazioni da riga di comando
- [ ] 3.2 Controllo che la connettivita' del PCB corrisponda allo schema
- [ ] 3.3 DRC e corrispondenza eseguiti in CI con la stessa severita' dell'ERC

## 4. Render

- [ ] 4.1 Render da piu' prospettive nella pipeline esistente
- [ ] 4.2 Pagina del PCB in docs/ con i render

## 5. Documentazione

- [ ] 5.1 Riscrivere in docs/decisioni.md il rinvio del PCB come decisione ribaltata, con il motivo
- [ ] 5.2 Documentare la doppia configurazione dell'alimentazione e l'inversione della logica di D2
