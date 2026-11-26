# Tasks

## 1. Decisioni da chiudere prima

- [x] 1.1 Scegliere il footprint dello XIAO sul PCB, motivando in docs/ l'effetto su altezza, recuperabilita' e saldatura
- [x] 1.2 Definire come si seleziona fra MOSFET e pilotaggio diretto, e cosa comporta per il firmware

## 1bis. Modelli tridimensionali mancanti

Senza questi il render mostra una scheda incompleta e la verifica di
accoppiamento misura meno di quello che dichiara.

- [x] 1bis.1 Il footprint `XIAO-ESP32-C6-DIP` porta modelli per cinque altri XIAO ma non per il C6, e li cerca sotto `${AMZPATH}`, che il progetto non definisce: decidere se procurare il modello, usare un altro XIAO come sostituto geometrico (stesso ingombro 21 x 17,5) o modellare un solido semplice
- [x] 1bis.2 Il breakout VL53L1X e' montato come header a 6 pin: in 3D compare l'header, non la scheda. Dare un corpo al breakout, altrimenti il vano che lo ospita non viene verificato
- [x] 1bis.3 Dichiarare in docs/ quali modelli sono sostituti e quali reali

Nota su 1bis.1: nessuno dei cinque STEP esiste in locale ne' nell'immagine
`kicad/kicad:10.0.8-full` della CI, quindi "usare un altro XIAO della
famiglia" non era praticabile. Si e' ripiegato sulla terza opzione, un
solido semplice in VRML che comprende anche l'header femmina.

## 2. Layout

- [x] 2.1 Assegnare i footprint e importare la netlist dallo schema
- [x] 2.2 Contorno scheda compatibile con i vani del contenitore
- [x] 2.3 Piazzamento e sbroglio, con il partitore vicino al pin ADC
- [x] 2.4 Interruttore a P-MOSFET con ponticello di esclusione

Nota su 2.2: il contorno (50 x 34 mm) sta nella larghezza del vano, ma
l'assieme e' alto 15 mm contro i 6,8 della cavita'. Il contenitore e'
dimensionato sulla millefori e va rifatto: vedi 4.4.

## 3. Verifica

- [x] 3.1 DRC senza violazioni da riga di comando
- [x] 3.2 Controllo che la connettivita' del PCB corrisponda allo schema
- [x] 3.3 DRC e corrispondenza eseguiti in CI con la stessa severita' dell'ERC

## 4. Render e accoppiamento

- [x] 4.1 Render da piu' prospettive con `kicad-cli pcb render`, usando `--rotate`, `--side` e `--perspective`
- [ ] 4.2 Export `glb` del PCB per la vista interattiva, con lo stesso visualizzatore del contenitore
- [x] 4.3 Export `stl` della scheda con i componenti, importato in OpenSCAD per la verifica di accoppiamento
- [x] 4.4 Verifica automatica che la scheda stia nel vano, che fallisca dicendo di quanto eccede e in quale direzione
- [x] 4.5 Provare la verifica sul caso che deve fallire: una scheda volutamente troppo grande
- [x] 4.6 Pagina del PCB in docs/ con render, vista interattiva ed esito dell'accoppiamento

Nota su 4.2, lasciato aperto: il `glb` viene esportato e pubblicato, ma il
visualizzatore del contenitore legge **STL binario** e non glTF. La vista
interattiva della pagina usa quindi un `pcb.stl`, e il `glb` resta un file
da scaricare. Per chiudere il task davvero servirebbe un lettore glTF nel
visualizzatore, che e' un lavoro a se'.

Nota su 4.4: il controllo c'e', e oggi dice **no** — la scheda eccede di
8,2 mm in altezza. Per questo non e' ancora un passo della CI: va attivato
insieme all'aggiornamento delle quote del contenitore, altrimenti lascia
la pipeline rossa.

## 5. Documentazione

- [x] 5.1 Riscrivere in docs/decisioni.md il rinvio del PCB come decisione ribaltata, con il motivo
- [x] 5.2 Documentare la doppia configurazione dell'alimentazione e l'inversione della logica di D2
