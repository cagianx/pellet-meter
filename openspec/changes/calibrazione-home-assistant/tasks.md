# Tasks

## 1. Conversione del livello

- [ ] 1.1 Template che converte la distanza in percentuale, con i due riferimenti isolati in testa
- [ ] 1.2 Limitare il risultato tra 0 e 100, cosi' una lettura fuori scala non produce valori assurdi
- [ ] 1.3 Variante con tabella di interpolazione, per il caso di fondo a imbuto
- [ ] 1.4 Documentare come si ricavano i due riferimenti e dove si inseriscono

## 2. Avvisi

- [ ] 2.1 Automazione di avviso sotto soglia, con la soglia come parametro
- [ ] 2.2 Evitare che l'avviso si ripeta a ogni lettura sotto soglia

## 3. Grandezze derivate

- [ ] 3.1 Rilevamento della ricarica dal salto di livello, con soglia sul rumore come parametro
- [ ] 3.2 Stima del consumo in kg al giorno
- [ ] 3.3 Stima dell'autonomia residua
- [ ] 3.4 Documentare i limiti di queste stime: dipendono da densita' del pellet e geometria

## 4. Confezionamento

- [ ] 4.1 Configurazione in `homeassistant/`, commentata e copiabile
- [ ] 4.2 Indicare come verificare i nomi reali delle entita' create da BTHome
