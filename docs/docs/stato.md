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
| Scheletro del firmware | Progetto ESP-IDF che compila per esp32c6, switch RF dell'antenna |
| CI firmware | Verde, nel container `espressif/idf:v5.5` |
| Contenitore | Modello OpenSCAD parametrico, quote verificate contro il solido |
| Render | Schema nel sito e nel README; contenitore in tre viste piu' una quotata e un modello ruotabile. Li produce la CI |
| Documentazione | Questo sito |

## Cosa fornisce questo progetto

Il repo fornisce **il progetto**, non la realizzazione: schema elettrico,
firmware, modello del contenitore e configurazione di Home Assistant, con i
criteri per verificarli.

Comprare i componenti, saldare, stampare, misurare la tramoggia e installare
sulla stufa sono attivita' di chi costruisce, e non sono tracciate qui. I
criteri di accettazione corrispondenti stanno nelle spec dei change: dicono
cosa deve risultare vero, senza possedere il gesto manuale che lo verifica.

## Da fare

Il lavoro e' tracciato con **OpenSpec**, in `openspec/changes/`. Ogni change
ha proposal (perche'), spec (cosa deve fare), design (come) e task.

| Change | Task aperti | Contenuto |
|---|---|---|
| `pcb-kicad` | 16 di 20 | Layout del PCB, verifica di accoppiamento con il contenitore, render della scheda |
| `firmware-bthome` | 14 di 19 | Acquisizione, pacchetto BTHome, ciclo di deep sleep |
| `calibrazione-home-assistant` | 13 di 13 | Template di calibrazione, avvisi, grandezze derivate |
| `contenitore-montaggio` | 11 di 11 | Tappo USB-C, superficie di incollaggio, chiusura a scatto |
| `schema-leggibile` | 8 di 10 | Disposizione dello schema nella GUI, lavoro da fare in KiCad |
| `immagine-di-sviluppo` | 4 di 10 | Resta l'adozione dell'immagine nei workflow |

Archiviati, con le spec passate in `openspec/specs/`:

| Change | Capability |
|---|---|
| `contenitore-3d` | `contenitore` — forma, aperture e vincoli meccanici dell'involucro |
| `render-ricchi` | `render` — viste, quote e vista interattiva dei modelli |

```bash
openspec list                 # stato dei change
openspec show <nome>          # un change nel dettaglio
openspec validate --all
```

Nessuno dei quattro dipende dagli altri per iniziare. Le tre decisioni che
bloccavano `firmware-bthome` sono chiuse: framework **ESP-IDF 5.x + NimBLE**,
device info **`0x44`** (trigger-based), risveglio ogni **10 minuti**. Le
ragioni sono in [Decisioni di progetto](/decisioni/) e in
[Firmware](/software/firmware/).

## I numeri che mancano

Due valori non si possono ricavare a tavolino e vanno inseriti da chi
installa: la distanza dal coperchio al pellet **a serbatoio pieno** e **a
serbatoio vuoto**. Serve anche sapere se il fondo e' a imbuto, perche' in
quel caso la conversione lineare sbaglia.

Il progetto non li misura: li tratta come parametri, e il compito dei change
e' renderli facili da inserire e da cambiare.

## Decisioni ancora aperte

- Cifratura BTHome con bindkey: opzionale, si valuta dopo
- Soglia di avviso e soglia sul rumore per il rilevamento della ricarica:
  sono parametri del change `calibrazione-home-assistant`

Con `0x44` il dispositivo non risulta **mai** non disponibile in Home
Assistant: il controllo di vitalita' va fatto sull'eta' del dato. E' un
requisito che ricade su `calibrazione-home-assistant`.

## Idee rimandate

- **PCB** in KiCad al posto della millefori, da produrre con Aisler o
  JLCPCB. Deliberatamente rimandato: il PCB congela in rame scelte che il
  prototipo puo' ancora ribaltare.
- **Cifratura BTHome** con bindkey.
