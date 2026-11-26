# Spec Delta

## Purpose

Definisce l'ambiente riproducibile in cui si verificano schema, contenitore
e documentazione, condiviso tra chi sviluppa e la CI.

## ADDED Requirements

### Requirement: Definizione unica degli strumenti

La catena di strumenti SHALL essere dichiarata in un solo file versionato.

#### Scenario: Serve uno strumento nuovo
- **WHEN** una verifica richiede uno strumento non presente
- **THEN** lo strumento si aggiunge al `Dockerfile`
- **AND** nessun workflow installa pacchetti al volo

#### Scenario: Strumento mancante
- **WHEN** un workflow gira e uno strumento richiesto non c'e'
- **THEN** il workflow fallisce
- **AND** non prosegue saltando il passo che ne aveva bisogno

### Requirement: Stesso ambiente in locale e in CI

Chi sviluppa SHALL poter eseguire le stesse verifiche della CI senza
installare gli strumenti sulla propria macchina.

#### Scenario: Riproduzione di un guasto della CI
- **WHEN** un controllo fallisce in CI
- **THEN** la stessa esecuzione e' riproducibile in locale nella stessa
  immagine
- **AND** non serve indovinare quali strumenti avesse il container

### Requirement: Comportamento della shell non scoperto a runtime

I job in container SHALL dichiarare esplicitamente la shell.

#### Scenario: Passo che usa costrutti di bash
- **WHEN** un passo di un workflow usa un costrutto specifico di bash
- **THEN** il passo gira sotto bash
- **AND** non viene interpretato da una shell scelta automaticamente

### Requirement: Ricostruzione solo quando serve

L'immagine SHALL essere ricostruita e pubblicata quando cambia la sua
definizione, non a ogni commit.

#### Scenario: Commit che non tocca l'ambiente
- **WHEN** si committa una modifica che non riguarda gli strumenti
- **THEN** l'immagine non viene ricostruita
- **AND** i workflow usano quella gia' pubblicata
