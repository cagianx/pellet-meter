# Proposal

## Why

Il contenitore oggi e' una scatola con un coperchio appoggiato. Mancano tre
cose che dipendono da **come viene montato davvero**, e che sono emerse
solo ora che il montaggio e' deciso:

- va incollato **sotto** il coperchio della tramoggia, con biadesivo o
  velcro. Quindi niente viti nella lamiera, e il peso tira verso il basso:
  la superficie di incollaggio e la distribuzione del carico contano.
- la **USB-C** resta esposta verso l'interno della stufa. Un connettore
  aperto in un ambiente con polvere di pellet si sporca, e la polvere di
  legno e' abrasiva e igroscopica.
- il coperchio deve **restare chiuso**. Oggi lo tiene solo l'attrito del
  labbro: se si apre a testa in giu', dentro una tramoggia, la batteria
  cade nel pellet.

Sono tre requisiti meccanici, non rifiniture: a testa in giu' un
contenitore che si apre e' un guasto, non un inestetismo.

## What Changes

- Tappo per la USB-C, stampabile, trattenuto senza colla.
- Superficie di incollaggio piana e dimensionata per biadesivo o velcro,
  con l'area dichiarata come parametro.
- Chiusura del coperchio che non si affida al solo attrito.
- Il modello resta parametrico: ogni aggiunta ha i suoi parametri in testa
  al file.

## Capabilities

### Modified Capabilities
- `contenitore`: aggiunge protezione del connettore, fissaggio a incollaggio
  e ritenuta del coperchio.

## Impact

Modifica `enclosure/case.scad` e la pagina del contenitore in `docs/`.
Il controllo `tools/check_case.py` si estende ai pezzi nuovi.

Nessun impatto su firmware o schema.
