# Spec Delta

## Purpose

Definisce come Home Assistant trasforma la distanza grezza trasmessa dal
dispositivo in un livello di riempimento utile e nei relativi avvisi.

## ADDED Requirements

### Requirement: Conversione in percentuale

Home Assistant SHALL convertire la distanza in percentuale di riempimento
usando due distanze di riferimento, misurate a serbatoio pieno e vuoto.

#### Scenario: Lettura nei limiti
- **WHEN** arriva una distanza compresa tra i due riferimenti
- **THEN** la percentuale e' calcolata tra 0 e 100

#### Scenario: Lettura fuori dai limiti
- **WHEN** arriva una distanza oltre i riferimenti
- **THEN** il valore viene limitato a 0 o 100, senza produrre numeri assurdi

### Requirement: Ricalibrazione senza reflash

I riferimenti SHALL essere modificabili nella configurazione di Home Assistant.

#### Scenario: Nuova calibrazione
- **WHEN** si aggiorna una distanza di riferimento
- **THEN** il livello si ricalcola senza toccare il firmware

### Requirement: Avviso di scorta bassa

Home Assistant SHALL poter avvisare quando il livello scende sotto una soglia.

#### Scenario: Scorta in esaurimento
- **WHEN** il livello scende sotto la soglia configurata
- **THEN** viene generato un avviso

### Requirement: Rilevamento della ricarica

Il sistema SHALL riconoscere una ricarica da un aumento improvviso del livello.

#### Scenario: Serbatoio riempito
- **WHEN** il livello sale bruscamente
- **THEN** l'evento e' registrato come ricarica
- **AND** non viene interpretato come consumo negativo
