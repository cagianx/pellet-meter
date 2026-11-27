# Spec Delta

## MODIFIED Requirements

### Requirement: Linea di vista del sensore

Il contenitore SHALL lasciare libero il cono di misura del VL53L1X, e
l'apertura ottica SHALL trovarsi sulla faccia rivolta al pellet.

#### Scenario: Sensore in posizione
- **WHEN** il contenitore e' montato nel suo verso di installazione
- **THEN** l'apertura ottica guarda il pellet, non la superficie di
  fissaggio
- **AND** l'apertura non intercetta il fascio entro il cono utile

#### Scenario: Verso di montaggio sbagliato
- **WHEN** l'apertura ottica verrebbe a trovarsi sulla faccia incollata
- **THEN** la verifica lo segnala
- **AND** non si pubblica un contenitore che non puo' misurare

### Requirement: Parametrizzazione

Il modello SHALL esporre come parametri le quote dei componenti, lo
spessore delle pareti, le tolleranze di accoppiamento e la disposizione
interna.

#### Scenario: Cambio di batteria
- **WHEN** si modifica il parametro delle dimensioni della batteria
- **THEN** il modello si rigenera senza modifiche alla geometria scritta a mano

#### Scenario: Scelta della disposizione
- **WHEN** si cambia la disposizione fra cella accanto alla scheda e cella
  sovrapposta
- **THEN** il contenitore si rigenera di conseguenza
- **AND** non serve riscrivere geometria

## ADDED Requirements

### Requirement: Il sensore resta entro la portata utile

La distanza fra la faccia di fissaggio e il sensore SHALL essere tale che,
a serbatoio pieno, la distanza misurata resti sopra la portata minima del
sensore.

#### Scenario: Serbatoio pieno
- **WHEN** il pellet e' al livello massimo previsto
- **THEN** la distanza fra sensore e pellet e' maggiore della portata
  minima dichiarata
- **AND** il contenitore non consuma quel margine con il proprio spessore

#### Scenario: Contenitore troppo spesso sotto il sensore
- **WHEN** il sensore verrebbe a trovarsi piu' in basso di quanto il
  margine consenta
- **THEN** la verifica fallisce indicando di quanto

### Requirement: I vani seguono l'hardware reale

I vani SHALL essere dimensionati sugli oggetti che il dispositivo contiene
davvero, e le quote della scheda SHALL essere ricavate dal progetto del
PCB invece che ribattute.

#### Scenario: Il PCB cambia dimensione
- **WHEN** cambia l'ingombro della scheda o dei suoi componenti
- **THEN** la verifica di accoppiamento se ne accorge
- **AND** non resta una quota ribattuta a mano che dice il contrario

#### Scenario: Accoppiamento verificato in CI
- **WHEN** cambia il contenitore o il PCB
- **THEN** la verifica di accoppiamento viene eseguita dalla pipeline
- **AND** una scheda che non entra fa fallire la pipeline
