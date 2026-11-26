# Spec Delta

## Purpose

Definisce l'involucro stampato in 3D che tiene elettronica e batteria fuori
dal serbatoio, lasciando al sensore ToF una linea di vista libera verso la
superficie del pellet.

## ADDED Requirements

### Requirement: Separazione tra elettronica e serbatoio

Il contenitore SHALL tenere scheda e batteria all'esterno del serbatoio,
esponendo verso l'interno solo la finestra ottica del sensore.

#### Scenario: Montaggio sul coperchio
- **WHEN** il contenitore e' montato sul coperchio della tramoggia
- **THEN** nessuna parte dell'elettronica o della batteria sporge nel serbatoio
- **AND** il contenitore non tocca coclea ne' microinterruttore di sicurezza

### Requirement: Linea di vista del sensore

Il contenitore SHALL lasciare libero il cono di misura del VL53L1X.

#### Scenario: Sensore in posizione
- **WHEN** il sensore e' montato e guarda verso il basso
- **THEN** l'apertura non intercetta il fascio entro il cono utile
- **AND** la finestra ottica si trova almeno 4-5 cm sopra il livello massimo del pellet

### Requirement: Ricarica senza smontaggio

Il contenitore SHALL permettere di collegare la USB-C a contenitore chiuso.

#### Scenario: Ricarica
- **WHEN** l'utente collega un cavo USB-C
- **THEN** il connettore e' raggiungibile senza aprire il contenitore

### Requirement: Parametrizzazione

Il modello SHALL esporre come parametri le quote dei componenti, lo spessore
delle pareti e le tolleranze di accoppiamento.

#### Scenario: Cambio di batteria
- **WHEN** si modifica il parametro delle dimensioni della batteria
- **THEN** il modello si rigenera senza modifiche alla geometria scritta a mano
