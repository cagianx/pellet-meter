# Tasks

## 1. Conversione del livello

La tramoggia e' stata misurata: **50 mm** a pieno carico, **800-900 mm** a
vuoto, **fondo a imbuto**. L'imbuto non e' piu' un caso ipotetico, quindi
la tabella di interpolazione non e' piu' una variante: e' la strada
principale, e la conversione lineare resta solo come caso semplice per
tramogge a pareti dritte.

- [ ] 1.1 Tabella di interpolazione distanza → percentuale, con i punti isolati in testa e facili da cambiare
- [ ] 1.2 Limitare il risultato tra 0 e 100, cosi' una lettura fuori scala non produce valori assurdi
- [ ] 1.3 Conversione lineare come caso semplice, per chi ha una tramoggia a pareti dritte
- [ ] 1.4 Documentare come si ricavano i punti della tabella e dove si inseriscono
- [ ] 1.5 Spiegare perche' con l'imbuto la percentuale di riempimento non e' proporzionale al pellet che resta: in fondo alla corsa un grosso calo di livello vale pochi chili

## 2. Avvisi

- [ ] 2.1 Automazione di avviso sotto soglia, con la soglia come parametro
- [ ] 2.2 Evitare che l'avviso si ripeta a ogni lettura sotto soglia
- [ ] 2.3 Avviso di dato fermo basato sull'eta' dell'ultimo aggiornamento, non sulla disponibilita': con device info `0x44` l'entita' risulta sempre disponibile

## 3. Grandezze derivate

- [ ] 3.1 Rilevamento della ricarica dal salto di livello, con soglia sul rumore come parametro
- [ ] 3.2 Stima del consumo in kg al giorno
- [ ] 3.3 Stima dell'autonomia residua
- [ ] 3.4 Documentare i limiti di queste stime: dipendono da densita' del pellet e geometria, e con il fondo a imbuto l'errore cresce verso il fondo della corsa
- [ ] 3.5 Avviso di lettura fuori portata: a serbatoio pieno restano ~6 mm di margine sul minimo del sensore, e oltre il colmo le letture non sono valide

## 4. Confezionamento

- [ ] 4.1 Configurazione in `homeassistant/`, commentata e copiabile
- [ ] 4.2 Indicare come verificare i nomi reali delle entita' create da BTHome
