# Spec Delta

## ADDED Requirements

### Requirement: Corrispondenza con lo schema

Il PCB SHALL avere la stessa connettivita' dello schema elettrico.

#### Scenario: Rete modificata sullo schema
- **WHEN** lo schema cambia una rete
- **THEN** la verifica segnala il PCB non allineato
- **AND** il disallineamento non resta silenzioso

### Requirement: Alimentazione del sensore reversibile

Il PCB SHALL permettere sia l'interruttore high-side a P-MOSFET sia il
pilotaggio diretto da GPIO, senza modifiche al rame.

#### Scenario: Prototipo come oggi
- **WHEN** si sceglie il pilotaggio diretto
- **THEN** il sensore e' alimentato dal GPIO
- **AND** il MOSFET non va montato

#### Scenario: Le misure mostrano cali di tensione
- **WHEN** si monta il MOSFET
- **THEN** l'alimentazione del sensore passa dall'interruttore high-side
- **AND** la documentazione dichiara che la logica di D2 si inverte

### Requirement: Verifica automatica del layout

Il PCB SHALL superare il DRC senza violazioni.

#### Scenario: Verifica in CI
- **WHEN** il PCB cambia
- **THEN** il DRC viene eseguito
- **AND** una violazione fa fallire la pipeline

### Requirement: Render della scheda con i componenti

Il PCB SHALL essere pubblicato come render tridimensionale da piu'
prospettive, con i componenti montati.

#### Scenario: Capire com'e' fatta la scheda
- **WHEN** si apre la pagina del PCB
- **THEN** sono visibili almeno il lato componenti e il lato opposto
- **AND** i componenti sono rappresentati, non solo il rame

#### Scenario: Componente senza modello 3D
- **WHEN** un footprint non ha un modello tridimensionale
- **THEN** la cosa e' dichiarata nella documentazione
- **AND** non si spaccia per un render completo un render che manca di un
  pezzo

### Requirement: Accoppiamento verificato con il contenitore

Il fatto che la scheda entri nel contenitore SHALL essere verificato
automaticamente, non dedotto da quote scritte a mano.

#### Scenario: Scheda che non entra
- **WHEN** la scheda, con i suoi componenti, eccede il vano che la ospita
- **THEN** la verifica fallisce
- **AND** indica di quanto e in quale direzione

#### Scenario: Contenitore o scheda modificati
- **WHEN** cambia la forma della scheda o un parametro del contenitore
- **THEN** la verifica viene rieseguita
- **AND** un accoppiamento diventato impossibile non resta silenzioso
