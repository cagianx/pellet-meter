# Tasks

## 1. Disposizione

Il render ha reso misurabili i difetti: etichette `BAT_SENSE` sovrapposte
sul partitore, `GND` e `100nF` collisi su C3, contenuto in 234x129 mm sul
24% di un A3. Dettagli nella pagina Schema elettrico del sito.

- [ ] 1.1 Aprire lo schema nella GUI di KiCad
- [ ] 1.2 Separare i blocchi: alimentazione e batteria, misura, sensore
- [ ] 1.3 Avvicinare ogni nota alla parte che commenta
- [ ] 1.4 Distribuire i componenti sul foglio, o ridurre il formato se A3 e' troppo

## 2. Verifica che nulla sia cambiato

- [ ] 2.1 ERC ancora a zero violazioni
- [ ] 2.2 `check_netlist.py` passa senza toccare le reti attese
- [ ] 2.3 Controllo visivo del PDF esportato

## 3. Pubblicazione nel sito

- [x] 3.1 Decidere come l'SVG arriva nel sito (vedi Open Questions nel design)
- [x] 3.2 Inserire lo schema nella pagina `hardware/schema`
- [ ] 3.3 Verificare che la pagina si veda bene anche da telefono
