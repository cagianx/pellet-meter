---
title: "Stato e lavori aperti"
description: "A che punto e' il progetto e dove sono tracciati i lavori."
---

# Stato e lavori aperti

## Fatto

| | |
|---|---|
| Schema elettrico | ERC a 0 violazioni, 7 reti verificate nodo per nodo |
| Librerie di progetto | Simbolo e footprint XIAO, simbolo breakout VL53L1X |
| CI hardware | Verde, nel container KiCad 10.0.8 |
| Documentazione | Questo sito |

## Da fare

Il lavoro e' tracciato con **OpenSpec**, in `openspec/changes/`. Ogni change
ha proposal (perche'), spec (cosa deve fare), design (come) e task.

| Change | Task | Contenuto |
|---|---|---|
| `contenitore-3d` | 12 | Misure, modello OpenSCAD parametrico, verifica STL |
| `firmware-bthome` | 16 | Ciclo deep sleep, misura, pacchetto BTHome, consumi reali |
| `calibrazione-home-assistant` | 10 | Template di calibrazione, avvisi, grandezze derivate |

```bash
openspec list                 # stato dei change
openspec show <nome>          # un change nel dettaglio
openspec validate --all
```

## Il collo di bottiglia

**Misurare la tramoggia.** Distanza dal coperchio al pellet a serbatoio pieno
e a serbatoio vuoto, e forma del fondo.

Senza quei numeri, il contenitore si disegna su quote da datasheet e la
calibrazione di Home Assistant resta con valori segnaposto. E' il primo task
sia di `contenitore-3d` sia di `calibrazione-home-assistant`, e non e' un
caso.

## Decisioni ancora aperte

Registrate come Open Questions nel design di `firmware-bthome`:

- Framework: ESP-IDF oppure Arduino
- Intervallo di risveglio (proposta iniziale: 10 minuti)
- Device info `0x40` oppure `0x44`, da decidere verificando come Home
  Assistant gestisce la disponibilita'
- Cifratura BTHome con bindkey: opzionale

## Idee rimandate

- **PCB** in KiCad al posto della millefori, da produrre con Aisler o
  JLCPCB. Deliberatamente rimandato: il PCB congela in rame scelte che il
  prototipo puo' ancora ribaltare.
- **Cifratura BTHome** con bindkey.
