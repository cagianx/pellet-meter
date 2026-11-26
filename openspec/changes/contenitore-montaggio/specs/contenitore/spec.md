# Spec Delta

## ADDED Requirements

### Requirement: Protezione del connettore USB-C

Il contenitore SHALL proteggere la USB-C dalla polvere quando non e' in
uso, con un tappo che non si separa dal contenitore.

#### Scenario: Dispositivo installato
- **WHEN** il dispositivo e' montato e non in carica
- **THEN** l'apertura USB-C e' chiusa dal tappo
- **AND** il tappo resta vincolato al contenitore anche da aperto

#### Scenario: Ricarica
- **WHEN** si deve collegare il cavo
- **THEN** il tappo si apre senza attrezzi
- **AND** non ostruisce l'inserimento del connettore

### Requirement: Fissaggio a incollaggio

Il contenitore SHALL offrire una superficie piana per biadesivo o velcro,
di area sufficiente a sostenere il proprio peso a testa in giu'.

#### Scenario: Montaggio sotto il coperchio
- **WHEN** il contenitore e' incollato sotto il coperchio della tramoggia
- **THEN** la superficie a contatto e' piana e continua
- **AND** la sua area e' almeno quella dichiarata come minima per il peso
  stimato

#### Scenario: Contenitore piu' grande
- **WHEN** i parametri dei componenti fanno crescere il contenitore
- **THEN** la verifica dell'area di incollaggio segnala se non e' piu'
  sufficiente

### Requirement: Ritenuta del coperchio

Il coperchio SHALL restare chiuso senza affidarsi al solo attrito.

#### Scenario: Contenitore capovolto
- **WHEN** il contenitore e' montato a testa in giu'
- **THEN** il coperchio resta in sede
- **AND** non si apre per il peso della batteria

#### Scenario: Apertura voluta
- **WHEN** si deve aprire il contenitore
- **THEN** il coperchio si apre a mano, senza attrezzi
