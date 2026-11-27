# Proposal

## Why

Il contenitore e' stato disegnato prima che esistesse il PCB, e due cose
non tornano. Entrambe sono emerse da verifiche automatiche, non da un
ripensamento.

**1. Il sensore guarda la lamiera.** Il contenitore si incolla sotto il
coperchio della tramoggia con la faccia del fondo, e l'apertura ottica sta
proprio in quella faccia: puntata contro il coperchio invece che contro il
pellet. Cosi' com'e' il dispositivo e' montabile e non misura niente.
L'errore e' nel design del change `contenitore-montaggio`, che ha fissato
il verso senza accorgersi di dove finiva il foro.

**2. La scheda non entra.** `tools/check_fit.py` lo dice in numeri: la
scheda con i componenti e' 50 x 34 x 15 mm, la cavita' 50,6 x 50,7 x 6,8.
Eccede di **8,20 mm in altezza**, e in larghezza avanzano **0,60 mm**.

La causa dell'altezza e' l'header femmina da 8,5 mm, conseguenza della
scelta di innestare il modulo invece di saldarlo a filo. La causa piu'
profonda e' che i vani sono dimensionati sui **componenti sciolti** della
millefori — scheda, cella, breakout, ciascuno col suo vano — mentre ora
esiste **una scheda sola** che porta modulo, breakout e passivi. Il
contenitore descrive un prototipo che non e' piu' quello che si costruisce.

## What Changes

- L'apertura ottica si sposta sulla faccia che guarda il pellet.
- I vani si ridisegnano attorno alla scheda vera e alla cella, non attorno
  ai componenti sciolti.
- `check_fit.py` entra in CI, perche' da quel momento puo' restare verde.

## Capabilities

### Modified Capabilities
- `contenitore`: cambia la faccia su cui si affaccia l'ottica e la
  struttura interna dei vani.

## Impact

`enclosure/case.scad`, `tools/check_case.py`, `tools/check_fit.py`,
`.github/workflows/hardware.yml` e le pagine del contenitore in `docs/`.

Il contenitore crescera'. **Di quanto sia accettabile dipende da un dato
che non abbiamo**: lo spazio sotto il coperchio della tramoggia. Vedi
design.md.
