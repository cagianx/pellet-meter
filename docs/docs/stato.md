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

I change sono elencati **in ordine di dipendenza**, non di importanza.

| # | Change | Task | Contenuto |
|---|---|---|---|
| 1 | `prototipo-hardware` | 18 | Acquisto, breadboard, **prova sul pellet reale**, saldatura |
| 2 | `firmware-bthome` | 16 | Ciclo deep sleep, misura, pacchetto BTHome, consumi reali |
| 3 | `contenitore-3d` | 12 | Misure, modello OpenSCAD parametrico, verifica STL |
| 4 | `calibrazione-home-assistant` | 10 | Template di calibrazione, avvisi, grandezze derivate |
| — | `schema-leggibile` | 10 | Disposizione dello schema nella GUI, pubblicazione nel sito |

`schema-leggibile` e' fuori ordine perche' non dipende da nulla: si puo'
fare in qualsiasi momento.

```bash
openspec list                 # stato dei change
openspec show <nome>          # un change nel dettaglio
openspec validate --all
```

## Da dove si comincia

Due cose bloccano tutto il resto, e vanno fatte sul posto con la stufa
davanti.

**1. La prova del sensore sul pellet reale** (`prototipo-hardware`, gruppo 3).
E' la verifica che l'intero progetto sta in piedi: un ToF dentro una
tramoggia deve vedersela con polvere, riflessi, coperchio chiuso e superficie
a cono. Se il VL53L1X non regge, cambia il sensore — e con lui schema,
firmware e contenitore. Per questo viene prima del firmware completo: basta
uno sketch che stampi la distanza.

**2. Misurare la tramoggia.** Distanza dal coperchio al pellet a serbatoio
pieno e vuoto, e forma del fondo. Senza quei numeri il contenitore si disegna
su quote da datasheet e la calibrazione resta con valori segnaposto. E' il
primo task sia di `contenitore-3d` sia di `calibrazione-home-assistant`, e
non e' un caso.

Finche' queste due non sono fatte, tre change su cinque lavorano su ipotesi.

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
