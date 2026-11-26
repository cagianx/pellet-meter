---
title: "Componenti"
description: "Lista della spesa, dove comprare, e cosa evitare."
---

# Componenti

## Lista per un esemplare

| Q.tà | Componente | Note |
|---|---|---|
| 1 | Seeed XIAO ESP32C6 | Amazon ~17 €; Mouser/OpenELAB 5–9 € |
| 1 | Breakout VL53L1X (I²C, 3–5 V) | Pololu 3415, Adafruit, o equivalenti |
| 1 | LiPo 3,7 V 1000 mAh **con circuito di protezione** | Si salda sulle piazzole BAT+/BAT− dello XIAO |
| 2 | Resistenze 1 MΩ | Partitore per la misura della batteria |
| 1 | Condensatore 100 nF | C1, sul nodo del partitore |
| 1 | Condensatore 10 µF | C2, bulk sull'alimentazione del sensore |
| 1 | Condensatore 100 nF | C3, disaccoppiamento del sensore |
| — | Breadboard, cavetti, basetta millefori | Prototipo, poi saldatura |

Spesa stimata su Amazon con kit assortito e breadboard: **60–85 €**.

La distinta aggiornata viene generata dalla CI a partire dallo schema, come
artefatto `schema` (file `pellet-meter-bom.csv`).

## Cosa evitare

- **GY-53 e TOF400F**: hanno un microcontrollore a bordo o comunicano via
  seriale invece che I²C. Non sono breakout "nudi" del VL53L1X.
- **Resistenze da 100 kΩ per il partitore**: vedi
  [Decisioni di progetto](/decisioni/) — raddoppiano il consumo a riposo.

## Attenzioni pratiche

- **Togliere la pellicola protettiva** dal VL53L1X. Sembra ovvio, non lo e'.
- **L'ordine dei pin del breakout varia tra produttori.** Verificare la
  serigrafia della scheda prima di saldare: lo schema usa un header generico
  a 6 pin proprio perche' non e' standardizzato.
- **Controllare la polarita'** della LiPo prima di saldarla su BAT+/BAT−.
- **La LiPo non va caricata sopra i ~45 °C**: tenerla lontana dalle superfici
  calde della stufa.

## Link

- XIAO ESP32C6 — <https://www.amazon.it/dp/B0D2NKVB34>
- VL53L1X Happysnow — <https://www.amazon.it/dp/B0CNGP7LCR>
- RCWL-1601, ultrasuoni 3,3 V, 4 pz (solo per confronto) — <https://www.amazon.it/dp/B0C1N8PZCP>
- LiPo 603048 1000 mAh con protezione — <https://www.amazon.it/dp/B09YQ1Y3CY>
- Kit componenti assortiti 1390 pz — <https://www.amazon.it/dp/B07R49CSCJ>
- Breadboard ELEGOO 6×400 con cavetti — <https://www.amazon.it/dp/B0995TPNMT>

## Negozi fisici in zona

**Compel** (Carpenedo, Mestre), **CEM Elettronica** (Mestre), **Siben
Elettronica** (Castelfranco / Treviso). Vanno bene per resistenze,
condensatori e basette; per XIAO e VL53L1X conviene telefonare prima.
