---
title: "Firmware"
description: "Ciclo di funzionamento e vincoli di consumo."
---

# Firmware

:::warning
**Non ancora scritto.** Qui c'e' il progetto del ciclo e i vincoli da
rispettare. Il lavoro e' tracciato nel change OpenSpec `firmware-bthome`,
dove sono registrate anche le decisioni ancora aperte.
:::

## Ciclo di funzionamento

1. Risveglio dal timer RTC (uscita dal deep sleep).
2. **Impostare lo switch RF dell'antenna**, prima di toccare il BLE.
3. D2 a livello alto → attesa di avvio → inizializzazione del VL53L1X
   (distance mode short/medium, ROI ristretta se serve).
4. 5–7 misure → **mediana**, scartando le letture che il sensore segnala come
   non valide.
5. Lettura della batteria: ADC calibrato (`esp_adc_cali`) → mV × fattore del
   partitore → percentuale stimata dalla curva di scarica LiPo.
6. Costruzione del pacchetto BTHome e advertising per ~1 s (intervallo ~100 ms).
7. Spegnimento del sensore, stato sicuro di SDA/SCL/XSHUT, incremento del
   packet id in RTC memory, deep sleep.

## Vincoli da non violare

- **La distanza si trasmette grezza, in millimetri.** La conversione in
  percentuale sta in Home Assistant: metterla nel firmware significherebbe
  riflashare a ogni aggiustamento della calibrazione.
- **Se non resta nessuna lettura valida**, non si inventa una distanza: meglio
  non trasmettere quel dato che trasmetterne uno falso.
- **Il packet id sta in RTC memory**, l'unica memoria che sopravvive al deep
  sleep senza usurare la flash.
- **Il nodo del partitore va lasciato stabilizzare** prima di campionare:
  l'impedenza e' alta (500 kΩ) e C1 da 100 nF ha una costante di tempo di
  ~50 ms.
- **Prima di dormire**, SDA/SCL/XSHUT in uno stato che non alimenti il
  sensore spento attraverso i pull-up del breakout.

## Consumi stimati

| Scenario | Consumo | Autonomia con 1000 mAh |
|---|---|---|
| BLE advertising, risveglio ogni 15 min | ~1 mAh/giorno | oltre un anno (conta piu' l'autoscarica) |
| Wi-Fi + MQTT, per confronto | ~7 mAh/giorno | 4–5 mesi |

Sono stime: la misura reale del consumo in deep sleep e in trasmissione e' un
task aperto, ed e' la variabile che decide davvero l'autonomia.
