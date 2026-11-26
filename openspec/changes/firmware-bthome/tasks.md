# Tasks

## 1. Decisioni da chiudere prima

- [x] 1.1 Scegliere il framework tra ESP-IDF e Arduino, motivando la scelta in docs/
- [x] 1.2 Decidere device info `0x40` o `0x44`, documentando come HA gestisce la disponibilita' nei due casi
- [x] 1.3 Fissare l'intervallo di risveglio iniziale e il criterio per cambiarlo

## 2. Struttura del firmware

- [ ] 2.1 Progetto firmware che compila per XIAO ESP32C6, con istruzioni di build
- [ ] 2.2 Impostazione dello switch RF dell'antenna al risveglio, prima di inizializzare il BLE
- [ ] 2.3 Costruzione del pacchetto BTHome v2, oggetti in ordine crescente di ID
- [ ] 2.4 Advertising per circa un secondo, poi ritorno al deep sleep

## 3. Acquisizione

- [ ] 3.1 Accensione del sensore da D2 e inizializzazione del VL53L1X su I2C
- [ ] 3.2 Mediana di 5-7 misure, scartando le letture segnalate come non valide
- [ ] 3.3 Comportamento definito quando nessuna lettura e' valida: non inventare una distanza
- [ ] 3.4 Lettura della batteria con ADC calibrato e fattore del partitore
- [ ] 3.5 Attesa di stabilizzazione del nodo del partitore prima di campionare
- [ ] 3.6 Stima della percentuale dalla curva di scarica LiPo

## 4. Ciclo e consumo

- [ ] 4.1 Packet id in RTC memory, incrementato a ogni ciclo
- [ ] 4.2 Spegnimento del sensore e stato sicuro di SDA/SCL/XSHUT prima di dormire
- [ ] 4.3 Deep sleep con sveglia da timer
- [ ] 4.4 Calcolo del consumo atteso per ciclo, da confrontare poi con la misura sul banco

## 5. Documentazione

- [ ] 5.1 Procedura di build e caricamento in docs/
- [ ] 5.2 Come verificare il pacchetto trasmesso e cosa aspettarsi in Home Assistant
