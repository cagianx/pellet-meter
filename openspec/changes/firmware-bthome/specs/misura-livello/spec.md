# Spec Delta

## Purpose

Definisce come il dispositivo acquisisce la distanza dalla superficie del
pellet e lo stato della batteria a ogni risveglio.

## ADDED Requirements

### Requirement: Distanza grezza, non calibrata

Il firmware SHALL trasmettere la distanza misurata in millimetri, senza
convertirla in percentuale di riempimento.

#### Scenario: Ricalibrazione
- **WHEN** cambiano le distanze di riferimento del serbatoio
- **THEN** la ricalibrazione avviene in Home Assistant
- **AND** non richiede un nuovo caricamento del firmware

### Requirement: Robustezza della misura

Il firmware SHALL eseguire piu' misure per ciclo e trasmetterne la mediana,
scartando le letture che il sensore segnala come non valide.

#### Scenario: Letture sporche
- **WHEN** una parte delle letture e' non valida, per polvere o riflessi
- **THEN** le letture non valide sono escluse dal calcolo
- **AND** se non resta nessuna lettura valida il ciclo non trasmette una distanza inventata

### Requirement: Stato della batteria

Il firmware SHALL misurare la tensione della batteria e trasmettere sia i
millivolt sia una percentuale stimata.

#### Scenario: Lettura della tensione
- **WHEN** il firmware legge il nodo del partitore
- **THEN** usa l'ADC calibrato e applica il fattore del partitore
- **AND** attende che il nodo si sia stabilizzato prima di campionare

### Requirement: Consumo a riposo

Fuori dai cicli di misura il dispositivo SHALL restare in deep sleep, con il
sensore non alimentato.

#### Scenario: Prima di dormire
- **WHEN** il ciclo termina
- **THEN** l'alimentazione del sensore viene tolta
- **AND** le linee I2C sono messe in uno stato che non alimenta il sensore
  spento attraverso i pull-up del breakout
