# Spec Delta

## Purpose

Definisce cosa deve essere dimostrato sul circuito fisico prima di
considerare valide le scelte di progetto fatte sulla carta.

## ADDED Requirements

### Requirement: Misura affidabile nelle condizioni reali

Il sensore SHALL fornire letture stabili dentro la tramoggia, nelle
condizioni in cui lavorera' davvero.

#### Scenario: Prova a coperchio chiuso
- **WHEN** il sensore misura il pellet nella tramoggia con il coperchio chiuso
- **THEN** le letture ripetute sulla stessa superficie restano entro una
  dispersione accettabile per una stima del livello
- **AND** la presenza di polvere sulla finestra ottica non produce letture
  silenziosamente sbagliate

#### Scenario: Superficie irregolare
- **WHEN** la superficie del pellet e' a cono o inclinata, come dopo una ricarica
- **THEN** la mediana di piu' letture resta rappresentativa del livello

### Requirement: Decisione documentata sul sensore

L'esito della prova SHALL essere registrato, qualunque sia.

#### Scenario: Il sensore non e' adatto
- **WHEN** il VL53L1X non regge le condizioni reali
- **THEN** il motivo e le misure che lo dimostrano vengono scritti in docs/
- **AND** gli altri change vengono aggiornati con la conseguenza

### Requirement: Circuito montato in modo stabile

Il circuito definitivo SHALL essere saldato, non lasciato su breadboard.

#### Scenario: Montaggio sulla stufa
- **WHEN** il dispositivo viene installato
- **THEN** nessun collegamento dipende da un contatto a pressione
- **AND** la connettivita' corrisponde allo schema verificato
