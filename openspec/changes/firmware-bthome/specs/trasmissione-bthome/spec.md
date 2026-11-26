# Spec Delta

## Purpose

Definisce il pacchetto BLE che il dispositivo trasmette, in modo che Home
Assistant lo riconosca senza integrazioni personalizzate.

## ADDED Requirements

### Requirement: Solo advertising

Il dispositivo SHALL trasmettere in solo advertising, senza accettare
connessioni BLE.

#### Scenario: Ciclo radio
- **WHEN** il firmware ha i dati pronti
- **THEN** trasmette advertising per circa un secondo e torna in deep sleep

### Requirement: Formato BTHome v2

Il pacchetto SHALL essere un Service Data con UUID `0xFCD2`, con gli oggetti
in ordine crescente di ID.

#### Scenario: Composizione del pacchetto
- **WHEN** il firmware costruisce il pacchetto
- **THEN** contiene packet id, percentuale di batteria, tensione in mV e distanza in mm
- **AND** gli ID degli oggetti sono in ordine crescente

### Requirement: Scarto dei duplicati

Il pacchetto SHALL includere un contatore che si incrementa a ogni
trasmissione e sopravvive al deep sleep.

#### Scenario: Pacchetti ripetuti
- **WHEN** lo stesso pacchetto viene ricevuto piu' volte
- **THEN** Home Assistant puo' riconoscerlo come duplicato dal contatore

### Requirement: Antenna

Il firmware SHALL impostare lo switch RF dell'antenna a ogni risveglio, prima
di inizializzare il BLE.

#### Scenario: Risveglio
- **WHEN** il dispositivo si sveglia dal deep sleep
- **THEN** l'antenna viene selezionata prima dell'avvio della radio
- **AND** la potenza trasmessa non risulta attenuata
