# Proposal

## Why

Il sito oggi pubblica un render del contenitore: una immagine, una
angolazione, senza quote. Per chi deve capire **come e' fatto** e **quanto
e' grande** non basta.

Tre lacune concrete:

- **una sola prospettiva** nasconde meta' del pezzo. Il foro ottico,
  l'apertura USB-C e i vani interni non si vedono tutti dallo stesso punto.
- **nessuna quota**: un render senza dimensioni non dice se la scatola e'
  grande come un pacchetto di sigarette o come un libro.
- **immagine statica**: per un oggetto tridimensionale, poterlo ruotare
  vale piu' di qualunque numero di viste fisse.

## What Changes

- Piu' viste statiche per ogni pezzo, da angolazioni scelte per mostrare
  cose diverse, non per fare numero.
- Una variante **quotata** di ogni render, con le dimensioni principali.
- Un visualizzatore **interattivo** nel sito, che carica il modello e lo
  lascia ruotare.
- La pipeline di render resta una sola, e produce anche questi.

## Capabilities

### New Capabilities
- `render`: come i modelli del progetto diventano immagini pubblicate, e
  cosa deve essere leggibile da quelle immagini.

## Impact

Estende `tools/render.sh` e le pagine di `docs/`. Il visualizzatore
interattivo aggiunge risorse al sito, che vanno tenute locali: il sito non
deve dipendere da una CDN per mostrare un pezzo.

Si applica al contenitore subito; al PCB quando esistera' (change
`pcb-kicad`).
