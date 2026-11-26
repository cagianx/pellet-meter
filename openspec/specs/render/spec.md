# render Specification

## Purpose

Definisce come i modelli del progetto — schema, contenitore, scheda —
diventano immagini pubblicate, e cosa deve risultare leggibile da quelle
immagini: forma da piu' angolazioni, dimensioni, e la possibilita' di
ruotare cio' che e' tridimensionale.

## Requirements

### Requirement: Piu' viste per ogni pezzo

Ogni pezzo pubblicato SHALL essere mostrato da piu' angolazioni, scelte
per rendere visibili elementi diversi.

#### Scenario: Elemento nascosto in una vista
- **WHEN** un elemento del pezzo non e' visibile da una angolazione
- **THEN** esiste un'altra vista pubblicata che lo mostra

### Requirement: Render quotati

Per ogni pezzo SHALL esistere una variante con le dimensioni principali.

#### Scenario: Capire l'ingombro
- **WHEN** si guarda la pagina di un pezzo
- **THEN** le dimensioni principali sono leggibili dall'immagine
- **AND** non vanno cercate nel sorgente del modello

#### Scenario: Parametro cambiato
- **WHEN** un parametro del modello cambia una dimensione quotata
- **THEN** la quota pubblicata cambia di conseguenza
- **AND** non resta il valore precedente

### Requirement: Vista interattiva

I pezzi tridimensionali SHALL essere ruotabili nel sito.

#### Scenario: Esame della forma
- **WHEN** si apre la pagina di un pezzo tridimensionale
- **THEN** il modello si puo' ruotare
- **AND** le risorse necessarie sono servite dal sito, non da terze parti

#### Scenario: Senza JavaScript
- **WHEN** il visualizzatore non puo' funzionare
- **THEN** le immagini statiche restano visibili e sufficienti

### Requirement: Nessun render pubblicato a vuoto

La pubblicazione SHALL fallire se un'immagine referenziata manca o e'
vuota.

#### Scenario: Render non prodotto
- **WHEN** una vista referenziata non viene generata
- **THEN** la pubblicazione fallisce
- **AND** il sito non resta online con un riferimento rotto
