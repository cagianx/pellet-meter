---
title: "Firmware"
description: "Ciclo di funzionamento e vincoli di consumo."
---

# Firmware

:::warning
**Non ancora scritto.** Qui c'e' il progetto del ciclo e i vincoli da
rispettare. Il lavoro e' tracciato nel change OpenSpec `firmware-bthome`.
Le tre decisioni che bloccavano l'inizio sono chiuse, e sono qui sotto.
:::

## Le tre decisioni chiuse

### Framework: ESP-IDF 5.x con NimBLE

Le alternative erano Arduino (`arduino-esp32`) ed ESPHome. ESPHome era gia'
escluso: BTHome in trasmissione richiede un componente esterno, e porterebbe
di fatto la calibrazione nel dispositivo, contro una scelta di progetto
fissata.

Tra ESP-IDF e Arduino la ragione e' che **l'obiettivo del progetto e' il
consumo**, e ESP-IDF e' l'unico dei due che non mette strati tra il codice e
le tre cose che decidono l'autonomia: la sequenza di deep sleep, lo stato dei
GPIO prima di dormire, e lo switch RF dell'antenna. Il core Arduino inizializza
periferiche che poi vanno spente a mano, e il raw advertising va comunque
forzato: il risparmio di tempo iniziale si paga subito dopo.

Il costo della scelta e' il driver del sensore: in Arduino ci sono librerie
pronte (Pololu, SparkFun), in ESP-IDF si parte dall'**API ULD di ST**, che e'
C portabile e si innesta come componente scrivendo solo le funzioni di
piattaforma per l'I²C.

### Device info `0x44`, trigger-based

Decisa leggendo il codice di Home Assistant, non la documentazione: con il
bit trigger-based le entita' sono **sempre disponibili**, perche'
`BTHomeSensor.available` ritorna `True` quando il dispositivo e' *sleepy*.
Con `0x40` un solo advertisement perso puo' far sparire il dispositivo.
Dettagli, codice citato e il rovescio della medaglia — un dispositivo morto
non si distingue da uno vivo — in [Pacchetto BTHome](/software/bthome/).

### Intervallo di risveglio: 10 minuti

Il livello del pellet cambiando lentamente non ha bisogno di piu': una stufa
consuma nell'ordine di 1 kg/h e una tramoggia da 15–20 kg dura piu' di dieci
ore, quindi a 10 minuti si campiona **molto piu' spesso del necessario** per
il livello in se'. La granularita' serve al rilevamento della ricarica, che e'
un evento istantaneo.

Secondo motivo, piu' sottile: 600 s stanno sotto i **900 s** del fallback di
`habluetooth` per gli advertisement scaduti. Se un giorno il bit trigger-based
venisse tolto, il dispositivo non sparirebbe comunque per il solo fatto di
dormire.

**Il criterio per cambiare idea**, in entrambe le direzioni:

- si **allunga** (15 o 30 minuti) se il consumo misurato mette in pericolo
  l'obiettivo di oltre un anno di autonomia
- si **accorcia** solo se il rilevamento della ricarica perde eventi; non per
  avere un grafico piu' liscio, che e' il modo di spendere batteria per niente

## Build e caricamento

Il progetto sta in `firmware/`, e' un normale progetto ESP-IDF e il target e'
gia' scritto in `sdkconfig.defaults`: non serve `idf.py set-target`.

```bash
# dalla cartella firmware/, con l'ambiente ESP-IDF 5.x attivo
idf.py build
idf.py -p /dev/ttyACM0 flash monitor
```

Senza ESP-IDF installato, la stessa cosa nell'immagine ufficiale. Con
**podman**, che non ha daemon e gira senza privilegi:

```bash
podman run --rm -v "$PWD":/project:Z -w /project \
  docker.io/espressif/idf:v5.5 idf.py build
```

Con docker il comando e' lo stesso sostituendo `podman` con `docker`, ma
serve il daemon attivo e l'utente nel gruppo `docker` — che equivale a dare
privilegi di root. Per compilare firmware non c'e' motivo di pagare quel
prezzo.

:::note
Il suffisso `:Z` sul volume serve con SELinux attivo e non da' fastidio
altrove. Il flash invece **non** si fa dal container: servirebbe passargli
`/dev/ttyACM0`, e per un gesto che si fa a mano conviene usare l'ESP-IDF
installato in locale.
:::

:::note
La porta e' `/dev/ttyACM0`, non `/dev/ttyUSB0`: sullo XIAO ESP32C6 l'USB-C va
alla **USB Serial/JTAG nativa** del chip, non a un convertitore seriale. Per
lo stesso motivo in `sdkconfig.defaults` c'e'
`CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=y`: col default (UART) il monitor non
mostra niente e sembra che il firmware non parta.
:::

`sdkconfig` **non e' versionato**, perche' e' generato: la configurazione
deliberata sta tutta in `sdkconfig.defaults`, una ventina di righe
commentate. Il workflow CI `firmware` compila a ogni modifica e pubblica
binario e occupazione di flash.

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

:::note
La riga da ~1 mAh/giorno era calcolata su un risveglio ogni **15** minuti.
Con i 10 minuti decisi sopra i cicli al giorno passano da 96 a 144: cresce di
una volta e mezza la parte attiva, mentre la parte a riposo — ~17 µA tra
deep sleep dello XIAO e partitore, cioe' ~0,4 mAh al giorno — non cambia.
Quanto pesino l'una sull'altra lo dira' il calcolo per ciclo con i valori
veri, che e' il task 4.4 del change `firmware-bthome`.
:::
