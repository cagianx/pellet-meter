---
title: "Firmware"
description: "Ciclo di funzionamento e vincoli di consumo."
---

# Firmware

:::warning
**Scheletro in piedi, acquisizione e radio da scrivere.** In `firmware/`
c'e' un progetto ESP-IDF che compila per esp32c6 e che gestisce lo switch
RF dell'antenna; misura, pacchetto BTHome e deep sleep completo sono i task
ancora aperti del change `firmware-bthome`. Nel codice i punti mancanti
sono marcati con il numero del task.
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
3. Accensione del sensore (`sensor_power_set(true)`) → attesa di avvio →
   inizializzazione del VL53L1X (distance mode short/medium, ROI ristretta
   se serve).
4. 5–7 misure → **mediana**, scartando le letture che il sensore segnala come
   non valide.
5. Lettura della batteria: ADC calibrato (`esp_adc_cali`) → mV × fattore del
   partitore → percentuale stimata dalla curva di scarica LiPo.
6. Costruzione del pacchetto BTHome e advertising per ~1 s (intervallo ~100 ms).
7. Spegnimento del sensore, stato sicuro di SDA/SCL/XSHUT, incremento del
   packet id in RTC memory, deep sleep.

## Come e' alimentato il sensore: scelta a compile time

Sul PCB le due configurazioni dell'alimentazione del sensore convivono e si
scelgono col ponticello JP1 (vedi [Circuito stampato](/hardware/pcb/)).
**Fra le due la logica di D2 si inverte**, quindi la configurazione deve
essere esplicita anche nel firmware: montare il MOSFET e dimenticarsene
produce un sensore che non si accende mai, e sul banco sembra un sensore
guasto.

La decide una macro sola, in `firmware/main/pins.h`:

| `SENSORE_CON_MOSFET` | Rame | Livello per accendere |
|---|---|---|
| `0` (default) | JP1 su 1-2, Q1 e R3 non montati | `PIN_SENS_CTRL` **alto** |
| `1` | JP1 su 2-3, Q1 e R3 montati | `PIN_SENS_CTRL` **basso** |

Il default e' allineato al default del rame, cioe' la configurazione gia'
verificata sul prototipo. `sensor_power_set()` non conosce il livello: usa
`SENS_CTRL_ACCESO`, che la macro ricava.

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

Con il risveglio ogni 10 minuti, cioe' 144 cicli al giorno:

| Voce | Stima | Da dove viene |
|---|---|---|
| A riposo | ~0,4 mAh/giorno | ~17 µA continui: ~15 µA di deep sleep dello XIAO piu' ~2,1 µA del partitore |
| Parte attiva | ~0,9 mAh/giorno | 144 cicli di risveglio, misura e advertising |
| **Totale** | **~1,3 mAh/giorno** | oltre un anno con una LiPo da 1000 mAh |
| Wi-Fi + MQTT, per confronto | ~7 mAh/giorno | 4–5 mesi |

:::warning
**La parte attiva e' una stima propagata, non una misura.** Deriva da un
calcolo precedente fatto su un risveglio ogni 15 minuti, riscalato sui 144
cicli di oggi. Il consumo per ciclo con i valori veri e' il **task 4.4** del
change `firmware-bthome`, ed e' la variabile che decide davvero
l'autonomia: finche' non e' misurato, il totale qui sopra va letto come un
ordine di grandezza.
:::
