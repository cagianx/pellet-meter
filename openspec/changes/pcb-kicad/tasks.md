# Tasks

## 1. Decisioni da chiudere prima

- [x] 1.1 Scegliere il footprint dello XIAO sul PCB, motivando in docs/ l'effetto su altezza, recuperabilita' e saldatura
- [x] 1.2 Definire come si seleziona fra MOSFET e pilotaggio diretto, e cosa comporta per il firmware

## 1bis. Modelli tridimensionali mancanti

Senza questi il render mostra una scheda incompleta e la verifica di
accoppiamento misura meno di quello che dichiara.

- [x] 1bis.1 Il footprint `XIAO-ESP32-C6-DIP` porta modelli per cinque altri XIAO ma non per il C6, e li cerca sotto `${AMZPATH}`, che il progetto non definisce: decidere se procurare il modello, usare un altro XIAO come sostituto geometrico (stesso ingombro 21 x 17,5) o modellare un solido semplice
- [x] 1bis.2 Il breakout VL53L1X e' montato come header a 6 pin: in 3D compare l'header, non la scheda. Dare un corpo al breakout, altrimenti il vano che lo ospita non viene verificato
- [ ] 1bis.3 Dichiarare in docs/ quali modelli sono sostituti e quali reali

## 2. Layout

- [ ] 2.1 Assegnare i footprint e importare la netlist dallo schema
- [ ] 2.2 Contorno scheda compatibile con i vani del contenitore
- [ ] 2.3 Piazzamento e sbroglio, con il partitore vicino al pin ADC
- [ ] 2.4 Interruttore a P-MOSFET con ponticello di esclusione

## 3. Verifica

- [ ] 3.1 DRC senza violazioni da riga di comando
- [ ] 3.2 Controllo che la connettivita' del PCB corrisponda allo schema
- [ ] 3.3 DRC e corrispondenza eseguiti in CI con la stessa severita' dell'ERC

## 4. Render e accoppiamento

- [ ] 4.1 Render da piu' prospettive con `kicad-cli pcb render`, usando `--rotate`, `--side` e `--perspective`
- [ ] 4.2 Export `glb` del PCB per la vista interattiva, con lo stesso visualizzatore del contenitore
- [ ] 4.3 Export `stl` della scheda con i componenti, importato in OpenSCAD per la verifica di accoppiamento
- [ ] 4.4 Verifica automatica che la scheda stia nel vano, che fallisca dicendo di quanto eccede e in quale direzione
- [ ] 4.5 Provare la verifica sul caso che deve fallire: una scheda volutamente troppo grande
- [ ] 4.6 Pagina del PCB in docs/ con render, vista interattiva ed esito dell'accoppiamento

## 5. Documentazione

- [ ] 5.1 Riscrivere in docs/decisioni.md il rinvio del PCB come decisione ribaltata, con il motivo
- [ ] 5.2 Documentare la doppia configurazione dell'alimentazione e l'inversione della logica di D2
