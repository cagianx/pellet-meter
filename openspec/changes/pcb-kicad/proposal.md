# Proposal

## Why

Serve un render della scheda da piu' prospettive, e oggi non esiste
nessuna scheda: il prototipo e' su millefori e il PCB era stato
**deliberatamente rimandato**.

La ragione del rinvio era precisa, ed e' scritta in `docs/decisioni.md`:
un PCB congela in rame scelte che il prototipo puo' ancora ribaltare. La
piu' concreta e' l'alimentazione del sensore, oggi presa direttamente dal
GPIO D2, con l'upgrade a P-MOSFET annotato sullo schema come possibile.

Questo change **ribalta quel rinvio**, e lo fa con un accorgimento che ne
neutralizza il motivo: il PCB prevede il MOSFET **e** il collegamento
diretto, selezionabili, cosi' il rame non decide al posto delle misure.

## What Changes

- Layout PCB in KiCad a partire dallo schema esistente, che resta la fonte
  di verita'.
- Interruttore high-side a P-MOSFET presente sul rame, con la possibilita'
  di escluderlo e tornare al pilotaggio diretto da GPIO.
- Render 3D della scheda da piu' prospettive, nella pipeline esistente.
- Nessuna produzione: il change fornisce il progetto, non le schede.

## Capabilities

### New Capabilities
- `pcb`: il circuito stampato, i suoi vincoli e cosa deve restare
  reversibile.

## Impact

Nuovo `kicad/pellet-meter.kicad_pcb` e nuove regole di verifica (DRC).
`tools/render.sh` ha gia' il ramo per il render del PCB, oggi saltato
perche' il file non esiste.

La decisione rinviata va riscritta in `docs/decisioni.md`: non si cancella
la vecchia, si dice che e' stata ribaltata e perche'.
