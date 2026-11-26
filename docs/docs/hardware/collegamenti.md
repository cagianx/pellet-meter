---
title: "Collegamenti"
description: "Piedinatura, reti e le insidie del montaggio."
---

# Collegamenti

## Reti

| Rete | Collegamenti |
|---|---|
| `VBAT` | LiPo +, pad VBAT dello XIAO, R1 |
| `BAT_SENSE` | R1 / R2 / C1 → **D0** (GPIO0, ingresso ADC) |
| `VSENS` | **D2** (GPIO2) → VIN del breakout, C2, C3 |
| `SDA` | **D4** (GPIO22) → SDA del breakout |
| `SCL` | **D5** (GPIO23) → SCL del breakout |
| `XSHUT` | **D3** (GPIO21) → XSHUT del breakout |
| `GND` | LiPo −, R2, C1, C2, C3, GND del breakout, i tre GND dello XIAO |

`GPIO1` del breakout (l'interrupt) non e' collegato: con l'alimentazione
commutata non serve, ma il pin resta disponibile.

Lo schema con tutte le note e' in [Schema elettrico](/hardware/schema/).

## Insidie

### I pull-up I²C sono alimentati dalla rete del sensore

Il breakout ha i pull-up di SDA e SCL alimentati dal **proprio** rail, cioe'
dalla rete `VSENS`. Quando il firmware spegne il sensore mettendo D2 basso,
se SDA e SCL restano alti continuano a far passare corrente nel sensore
spento attraverso i pull-up.

**Prima di andare in deep sleep**, SDA, SCL e XSHUT vanno messi in uno stato
che non alimenti il sensore spento.

### Lo switch RF dell'antenna non e' sui pin del connettore

Lo XIAO ESP32C6 ha un selettore tra antenna integrata ed esterna, comandato
da GPIO **interni** che non compaiono sui 14 pin del connettore — e quindi
non compaiono nemmeno sullo schema.

Vanno impostati **a ogni risveglio**, prima di inizializzare il BLE.
Altrimenti l'advertising esce attenuato e il problema si manifesta come
"Home Assistant a volte non lo vede", che e' il tipo di guasto che fa perdere
un pomeriggio.

### Montaggio sulla stufa

- Il sensore guarda in basso dal coperchio, **almeno 4–5 cm sopra il livello
  massimo** del pellet.
- Non deve toccare l'interno della stufa, la coclea, ne' il microinterruttore
  di sicurezza del coperchio.
- Elettronica e batteria stanno **fuori** dal serbatoio.
