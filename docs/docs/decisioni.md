---
title: "Decisioni di progetto"
description: "Le scelte fatte, con la ragione dietro ciascuna, incluse quelle riviste."
---

# Decisioni di progetto

Ogni riga dice anche **perche'**: senza la motivazione, una decisione viene
ribaltata per distrazione sei mesi dopo.

## Scelte principali

| Tema | Scelta | Perche' |
|---|---|---|
| MCU | Seeed XIAO ESP32C6 | USB-C e caricabatterie LiPo gia' a bordo, deep sleep nell'ordine delle decine di µA, BLE 5 |
| Sensore | VL53L1X (ToF laser, I²C) | Misura da ~4 cm, niente zona cieca come gli ultrasuoni, fascio stretto con ROI programmabile, 3,3 V |
| Radio | BLE advertising, BTHome v2 | Riconosciuto nativamente da Home Assistant, consumo minimo, nessuna connessione da mantenere |
| Calibrazione | In Home Assistant, non nel firmware | Il firmware manda millimetri grezzi: ricalibrare non deve richiedere un riflash |
| Spegnimento sensore | Alimentato da un GPIO | Il VL53L1X assorbe poco; si spegne mettendo il pin a livello basso |
| Framework firmware | ESP-IDF 5.x + NimBLE | Nessuno strato tra il codice e le tre cose che decidono l'autonomia: deep sleep, stato dei GPIO, switch RF |
| Device info BTHome | `0x44`, trigger-based | In Home Assistant le entita' di un dispositivo *sleepy* sono sempre disponibili; con `0x40` un advertisement perso lo fa sparire |
| Intervallo di risveglio | 10 minuti | Molto piu' spesso del necessario per il livello, e sotto i 900 s del fallback di `habluetooth` |

## Decisioni riviste durante lo sviluppo

Queste sono cambiate rispetto all'idea iniziale. Vale la pena leggerle prima
di "correggerle" di nuovo.

### Partitore della batteria: 2×1 MΩ, non 100 kΩ

L'idea iniziale era un partitore con resistenze tra 100 kΩ e 1 MΩ. Fa una
differenza grossa, e nella direzione sbagliata:

- con **2×100 kΩ** a 4,2 V scorrono **~21 µA permanenti**, anche in deep sleep
- con **2×1 MΩ** scorrono **~2,1 µA**

Lo XIAO ESP32C6 in deep sleep dichiara ~15 µA. Con i 100 kΩ si **raddoppia il
consumo a riposo** per leggere la batteria una volta ogni dieci minuti: si
butta via meta' dell'autonomia per un dato che cambia lentissimo.

Il prezzo da pagare per 1 MΩ e' l'impedenza alta (500 kΩ equivalenti), che
l'ADC fatica a campionare: per questo c'e' **C1 da 100 nF** sul nodo. A 4,2 V
il nodo sta a 2,1 V, dentro il range dell'ADC con attenuazione a 12 dB.

### Alimentazione del sensore: GPIO diretto, con un criterio per cambiare idea

Il VL53L1X e' alimentato **direttamente dal GPIO D2**, senza MOSFET. La scelta
e' stata messa in discussione e poi confermata, e vale la pena sapere perche'
in entrambi i sensi.

**L'obiezione**: il GPIO dell'ESP32-C6 regge ~20 mA in sicurezza, il sensore
ne assorbe circa altrettanti in misura, con picchi quando spara il VCSEL. In
piu' la maggior parte dei breakout ha un regolatore e dei level shifter a
bordo, che aggiungono corrente di spunto all'accensione. C'e' il rischio di
brownout o letture instabili.

**Perche' si e' confermata comunque**: un P-MOSFET in SOT-23 su millefori
richiede un adattatore, e il prototipo serve esattamente a misurare se il
problema esiste. Aggiungere componenti per un guasto ipotizzato, prima di
averlo visto, e' il modo di non finire mai un prototipo.

**Il criterio per cambiare idea**: se le letture risultano instabili o il
sensore non si avvia, si passa a un interruttore high-side con **P-MOSFET
DMG2301L** (SOT-23), source a 3V3_OUT, drain a VSENS, gate a D2 con 100 kΩ di
pull-up verso 3V3_OUT. **Attenzione: con il MOSFET la logica si inverte**,
D2 basso significa sensore acceso.

Nel frattempo **C2 (10 µF)** e **C3 (100 nF)** sulla rete VSENS servono a
sostenere i picchi di corrente del VCSEL.

## Alternative valutate e scartate

| Opzione | Perche' no |
|---|---|
| HC-SR04 | Funziona a 5 V e assorbe ~2 mA a riposo: incompatibile con la batteria |
| JSN-SR04T / A02YYUW | Zona cieca di 20–25 cm, troppo per la tramoggia di una stufa |
| Shelly BLU Distance | Prodotto pronto (~25 €, BTHome nativo), ma il range parte da 0,25 m: valido **solo se** a serbatoio pieno restano ≥ 25 cm sotto il coperchio. Non si trova su Amazon.it |
| Wi-Fi + MQTT | ~7 mAh al giorno contro ~1,3: ridurrebbe l'autonomia a 4–5 mesi |
| ESPHome | BTHome con deep sleep richiede un componente esterno, e riporterebbe la calibrazione nel dispositivo |
| Arduino (`arduino-esp32`) | Librerie pronte per il VL53L1X, ma il core inizializza periferiche da spegnere a mano e il raw advertising va comunque forzato: il tempo risparmiato all'inizio si ripaga subito dopo, sul consumo |

## Riferimento architetturale

Il firmware [`ThyMYthOS/xm126-bthome-tank`](https://community.home-assistant.io/t/xm126-tank-level-volume-sensor-bthome-ble-firmware-updates-no-custom-integration-needed/1017506)
(Acconeer XM126) e' un buon riferimento per un sensore di serbatoio BTHome a
batteria: trasmette solo quando il valore cambia o allo scadere di un
intervallo massimo di heartbeat.

## Il rovescio della medaglia di `0x44`

Vale la pena saperlo prima di scoprirlo quando serve: dichiarando il
dispositivo *trigger-based*, Home Assistant non lo marca **mai** come non
disponibile. Batteria morta, sensore guasto e tutto funzionante hanno lo
stesso aspetto.

Il controllo di vitalita' va quindi fatto sull'**eta' del dato**, non sulla
disponibilita' dell'entita'. E' un requisito per il change
`calibrazione-home-assistant`, non un dettaglio del firmware. Il codice di
Home Assistant che lo determina e' citato in
[Pacchetto BTHome](/software/bthome/).

## Punti ancora aperti

Sono registrati come Open Questions nei change OpenSpec, vedi
[Stato e lavori aperti](/stato/):

- Cifratura BTHome con bindkey: opzionale, si valuta dopo
- Soglia di avviso e soglia sul rumore per il rilevamento della ricarica:
  parametri del change `calibrazione-home-assistant`
