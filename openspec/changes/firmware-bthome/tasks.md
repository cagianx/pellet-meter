# Tasks

## 1. Decisioni da chiudere prima

- [ ] 1.1 Scegliere il framework tra ESP-IDF e Arduino
- [ ] 1.2 Decidere device info `0x40` o `0x44` verificando come HA gestisce la disponibilita'
- [ ] 1.3 Fissare l'intervallo di risveglio iniziale

## 2. Portare su il minimo funzionante

- [ ] 2.1 Progetto firmware che compila e lampeggia, su XIAO ESP32C6
- [ ] 2.2 Impostare lo switch RF dell'antenna al risveglio
- [ ] 2.3 Advertising BTHome con valori fissi, verificare che HA scopra il dispositivo

## 3. Misura

- [ ] 3.1 Alimentare il sensore da D2 e inizializzare il VL53L1X su I2C
- [ ] 3.2 Mediana di 5-7 misure, scartando le letture non valide
- [ ] 3.3 Lettura batteria con ADC calibrato e fattore del partitore
- [ ] 3.4 Stima della percentuale dalla curva di scarica LiPo

## 4. Ciclo completo

- [ ] 4.1 Packet id in RTC memory, incrementato a ogni ciclo
- [ ] 4.2 Spegnimento sensore e stato sicuro di SDA/SCL/XSHUT prima di dormire
- [ ] 4.3 Deep sleep con sveglia da timer

## 5. Verifica sul campo

- [ ] 5.1 Misurare il consumo reale in deep sleep e in trasmissione
- [ ] 5.2 Verificare la ricezione in HA attraverso il proxy Bluetooth
- [ ] 5.3 Confrontare l'autonomia stimata con quella calcolata
