# Tasks

## 1. Verso dell'ottica

- [ ] 1.1 Spostare l'apertura ottica sulla faccia rivolta al pellet, mantenendo lo svaso conico ricavato da spessore e angolo
- [ ] 1.2 Riflettere il nuovo verso del breakout dove e' descritto: schema, collegamenti, pagina del PCB
- [ ] 1.3 Controllo che fallisca se l'apertura ottica finisce sulla faccia di fissaggio

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

## 4. Documentazione

- [ ] 4.1 Correggere in docs/ il verso di montaggio e togliere l'avviso che dice che il contenitore non misura
- [ ] 4.2 Registrare perche' i vani non sono piu' uno per componente, e quale dato manca per scegliere la disposizione
