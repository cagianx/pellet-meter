---
title: "Home Assistant"
description: "Calibrazione, avvisi e grandezze derivate."
---

# Home Assistant

Il dispositivo viene scoperto in automatico dall'integrazione **BTHome**.
Serve una ricezione Bluetooth locale oppure un **Bluetooth proxy ESPHome**.

## Calibrazione

Qui sta il motivo per cui il firmware manda millimetri grezzi: questi due
numeri si aggiustano senza toccare il dispositivo.

```yaml
template:
  - sensor:
      - name: "Pellet livello"
        unit_of_measurement: "%"
        state: >
          {% set d = states('sensor.pellet_meter_distance') | float(0) %}
          {% set vuoto = 380 %}{% set pieno = 60 %}
          {{ [[((vuoto - d) / (vuoto - pieno) * 100), 0] | max, 100] | min | round(0) }}
```

- `vuoto` / `pieno`: le distanze in mm misurate con serbatoio vuoto e pieno.
  **Vanno ancora misurate.**
- `sensor.pellet_meter_distance`: sostituire con il nome reale dell'entita'
  creata da BTHome, che va verificato.
- La formula limita il risultato tra 0 e 100, cosi' una lettura fuori scala
  non produce percentuali assurde.

:::note
**Se il fondo della tramoggia e' a imbuto**, la formula lineare sbaglia: il
volume non e' proporzionale alla distanza. In quel caso va sostituita con una
tabella di interpolazione. E' uno dei motivi per cui va misurata la forma del
fondo, non solo le due distanze.
:::

## Grandezze derivate

- Avviso quando il livello scende sotto una soglia (proposta: 20 %).
- Rilevamento della ricarica da un salto improvviso del livello. Serve una
  soglia che tenga conto del rumore di misura, altrimenti una lettura sporca
  viene scambiata per un riempimento.
- Da li', stima del consumo in kg/giorno e dell'autonomia residua. Resta
  indicativa: dipende dalla densita' del pellet e dalla geometria del
  serbatoio.

## Alternativa senza sensore

Per confronto: si puo' stimare il consumo dal tempo di funzionamento della
stufa con `history_stats`. Molto piu' grossolano, ma a costo zero.
