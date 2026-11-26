# Tasks

## 1. Immagine

- [ ] 1.1 `Dockerfile` basato su `kicad/kicad:10.0.8-full` con OpenSCAD, xvfb, librsvg, ImageMagick, Python e Node
- [ ] 1.2 Versioni fissate dove conta, e una riga di commento che dice a cosa serve ciascuno strumento
- [ ] 1.3 Un controllo dentro l'immagine che verifica la presenza di tutti gli strumenti attesi

## 2. Pubblicazione

- [ ] 2.1 Workflow che costruisce e pubblica su GHCR, attivato dal percorso del `Dockerfile`
- [ ] 2.2 Verificare che l'immagine pubblicata contenga davvero gli strumenti, non solo che il build passi

## 3. Adozione

- [ ] 3.1 `hardware` e `docs` usano l'immagine pubblicata, con `credentials` e shell dichiarata
- [ ] 3.2 Togliere dai workflow i passi di installazione al volo
- [ ] 3.3 Verificare che le due pipeline restino verdi e che i render continuino a essere pubblicati

## 4. Documentazione

- [ ] 4.1 Scrivere in docs/ come usare l'immagine in locale e come aggiungere uno strumento
- [ ] 4.2 Registrare in docs/ la catena del guasto che ha motivato il change: shell scelta automaticamente, `compgen` assente sotto dash, installazione saltata in silenzio
