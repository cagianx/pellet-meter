# Tasks

## 1. Verso dell'ottica

- [ ] 1.1 Spostare l'apertura ottica sulla faccia rivolta al pellet, mantenendo lo svaso conico ricavato da spessore e angolo
- [ ] 1.2 Riflettere il nuovo verso del breakout dove e' descritto: schema, collegamenti, pagina del PCB
- [ ] 1.3 Controllo che fallisca se l'apertura ottica finisce sulla faccia di fissaggio

## 1bis. Portata utile del sensore

Lo spazio misurato fra coperchio e pellet a pieno carico e' 50-70 mm, e il
VL53L1X misura da ~40 mm: nel caso peggiore il sensore puo' stare al
massimo 10 mm sotto il coperchio.

- [ ] 1bis.1 Portata minima del sensore e spazio disponibile a pieno carico come parametri
- [ ] 1bis.2 Scheda montata contro la faccia di fissaggio, cella sotto o accanto
- [ ] 1bis.3 Apertura ottica come tunnel conico che attraversa tutto il pezzo, non come foro nel solo fondo
- [ ] 1bis.4 Controllo che fallisca se il sensore finisce troppo in basso per misurare a serbatoio pieno

## 2. Vani sull'hardware reale

- [ ] 2.1 Ridisegnare i vani attorno a scheda assemblata e cella, togliendo il vano del breakout
- [ ] 2.2 Ricavare le quote della scheda dal `.kicad_pcb` invece di ribatterle in `case.scad`
- [ ] 2.3 Disposizione (cella accanto o sovrapposta) come parametro, non come geometria fissata
- [ ] 2.4 Dare aria vera in larghezza: 0,60 mm di margine oggi sono nulli contro le tolleranze di stampa

## 3. Verifica

- [ ] 3.1 `check_fit.py` passa contro il contenitore ridisegnato
- [ ] 3.2 `check_fit.py` entra nel workflow `hardware`
- [ ] 3.3 Provare che il controllo dica ancora di no quando deve: scheda troppo grande, e apertura ottica sulla faccia sbagliata
- [ ] 3.4 Le altre verifiche restano verdi: ERC, netlist, DRC con parita', `check_case.py`

## 4. Fissaggio e chiusura

Decisi con chi installa: **viti con dado** al coperchio della tramoggia, e
**una vite** che assicura il coperchio della scatola.

- [ ] 4.1 Fori passanti per il fissaggio al coperchio della tramoggia, con interasse e diametro come parametri
- [ ] 4.2 Vite di chiusura del coperchio della scatola, che **si aggiunge** allo scatto invece di sostituirlo: l'ottica sta sul coperchio, che guarda in giu', e se cede cadono scheda e cella
- [ ] 4.3 Il biadesivo resta come aiuto al montaggio, non come fissaggio: rivedere di conseguenza il controllo sull'area, che oggi presuppone sia lui a reggere
- [ ] 4.4 Altezza del modulo sopra la scheda come parametro, cosi' lo spessore segue la scelta di chi costruisce fra zoccolo e saldatura a filo

## 5. Documentazione

- [ ] 5.1 Correggere in docs/ il verso di montaggio e togliere l'avviso che dice che il contenitore non misura
- [ ] 5.2 Registrare perche' i vani non sono piu' uno per componente
- [ ] 5.3 Spiegare che il fissaggio meccanico sostituisce l'adesivo come elemento portante, e perche': sopra i ~60 gradi il PLA cede e l'adesivo scivola prima di strapparsi
