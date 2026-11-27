---
title: "Stato e lavori aperti"
description: "A che punto e' il progetto e dove sono tracciati i lavori."
---

# Stato e lavori aperti

## Fatto

| | |
|---|---|
| Schema elettrico | ERC a 0 violazioni, 10 reti verificate nodo per nodo |
| Librerie di progetto | Simbolo e footprint XIAO, simbolo breakout VL53L1X, simbolo DMG2301L, solido sostitutivo del modulo |
| Circuito stampato | Due strati, 50 x 34 mm, DRC e parita' con lo schema a 0 violazioni |
| CI hardware | Verde, nel container KiCad 10.0.8 |
| Scheletro del firmware | Progetto ESP-IDF che compila per esp32c6, switch RF dell'antenna |
| CI firmware | Verde, nel container `espressif/idf:v5.5` |
| Contenitore | Modello OpenSCAD parametrico, quote verificate contro il solido; tappo USB-C legato al corpo, faccia di incollaggio dimensionata sul peso, coperchio trattenuto a scatto |
| PCB | Layout a 2 strati, sbrogliato, DRC a 0 con parita' verificata contro lo schema |
| Render | Schema nel sito e nel README; contenitore e PCB in piu' viste, con quote e due modelli ruotabili. Li produce la CI |
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
| `pcb-kicad` | 1 di 20 | Resta l'attivazione in CI della verifica di accoppiamento, che oggi direbbe di no |
| `firmware-bthome` | 14 di 19 | Acquisizione, pacchetto BTHome, ciclo di deep sleep |
| `calibrazione-home-assistant` | 13 di 13 | Template di calibrazione, avvisi, grandezze derivate |
| `contenitore-montaggio` | 0 di 11, pronto da archiviare | Tappo USB-C, superficie di incollaggio, chiusura a scatto |
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

## I numeri della tramoggia

| Valore | Stato |
|---|---|
| Coperchio → pellet **a serbatoio pieno** | **50–70 mm**, misurato |
| Coperchio → pellet **a serbatoio vuoto** | manca |
| Fondo a imbuto? | manca — se lo e', la conversione lineare sbaglia |

Il progetto non li misura: li tratta come parametri, e il compito dei change
e' renderli facili da inserire e da cambiare.

:::warning
**I 50 mm del caso peggiore sono un vincolo di progetto, non un dato di
contorno.** Il VL53L1X misura da ~40 mm, quindi a serbatoio pieno il
sensore puo' stare al massimo **10 mm sotto il coperchio**: non puo'
trovarsi sul fondo del contenitore, perche' lo spessore dell'involucro si
mangerebbe la portata. Da qui la scheda montata in alto e l'apertura
ottica a tunnel conico, nel change `contenitore-sulla-scheda`.

Il margine che resta e' di **6 mm**. Riempiendo la tramoggia oltre il
colmo il sensore smette di dare letture valide: e' il motivo per cui il
firmware deve avere un comportamento definito quando nessuna lettura e'
valida, invece di inventare una distanza.
:::

## Decisioni ancora aperte

- Cifratura BTHome con bindkey: opzionale, si valuta dopo
- Soglia di avviso e soglia sul rumore per il rilevamento della ricarica:
  sono parametri del change `calibrazione-home-assistant`

Con `0x44` il dispositivo non risulta **mai** non disponibile in Home
Assistant: il controllo di vitalita' va fatto sull'eta' del dato. E' un
requisito che ricade su `calibrazione-home-assistant`.

## Idee rimandate

- **Cifratura BTHome** con bindkey.
