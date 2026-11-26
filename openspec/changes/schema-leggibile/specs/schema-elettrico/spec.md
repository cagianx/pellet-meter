# Spec Delta

## Purpose

Definisce cosa deve offrire lo schema elettrico a chi lo legge per montare o
rivedere il circuito, oltre alla correttezza delle connessioni.

## ADDED Requirements

### Requirement: Leggibilita' dello schema

Lo schema SHALL presentare i blocchi funzionali separati e riconoscibili,
occupando il foglio in modo uniforme.

#### Scenario: Lettura per il montaggio
- **WHEN** una persona apre il PDF dello schema per saldare il circuito
- **THEN** riconosce alimentazione, misura della batteria e sensore come gruppi distinti
- **AND** ogni nota tecnica si trova vicino alla parte che commenta

### Requirement: Le modifiche grafiche non alterano le connessioni

Qualunque intervento sulla disposizione SHALL lasciare invariata la
connettivita'.

#### Scenario: Dopo una modifica grafica
- **WHEN** lo schema viene risistemato nella GUI
- **THEN** l'ERC resta a zero violazioni
- **AND** la verifica della netlist continua a passare senza modificare le reti attese

### Requirement: Schema consultabile dalla documentazione

Il sito di documentazione SHALL mostrare lo schema senza richiedere il
download di artefatti o un account.

#### Scenario: Consultazione dal sito
- **WHEN** qualcuno apre la pagina dello schema elettrico sul sito
- **THEN** vede lo schema direttamente nella pagina
- **AND** l'immagine corrisponde alla versione corrente del file sorgente
