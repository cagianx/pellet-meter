# Tasks

## 1. Parametri di partenza

- [x] 1.1 Raccogliere da datasheet le quote di XIAO, LiPo 603048 e breakout VL53L1X
- [x] 1.2 Documentare quali parametri vanno rimisurati sull'esemplare reale e perche'
- [x] 1.3 Fissare i vincoli di montaggio come parametri: distanza minima dal pellet, spazio da lasciare a coclea e microinterruttore

## 2. Modello parametrico

- [x] 2.1 File `enclosure/case.scad` con tutti i parametri in testa
- [x] 2.2 Scocca con vani separati per scheda e batteria
- [x] 2.3 Apertura per la finestra ottica, con il cono di misura libero
- [x] 2.4 Apertura USB-C raggiungibile a contenitore chiuso
- [x] 2.5 Coperchio con accoppiamento guidato dal parametro di tolleranza

## 3. Verifica del modello

- [x] 3.1 Render STL da riga di comando, con controllo che il file non sia vuoto
- [x] 3.2 Controllo delle quote interne contro i parametri dichiarati
- [x] 3.3 Verificare che il modello si rigeneri cambiando i parametri dei componenti
- [ ] 3.4 Verificare che il job `contenitore` della CI diventi attivo e verde

## 4. Documentazione

- [x] 4.1 Scrivere in docs/ i parametri, come cambiarli e le tolleranze di stampa consigliate
