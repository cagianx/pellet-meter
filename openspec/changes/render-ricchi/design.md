# Design

## Context

`tools/render.sh` produce oggi un PNG per ogni `.scad` e l'SVG dello
schema. La pipeline e' una sola, usata in locale e in CI, e va tenuta tale.

## Goals / Non-Goals

**Goals:**
- Capire forma e dimensioni senza scaricare niente.
- Risorse del sito **locali**: niente CDN.
- Le viste aggiunte mostrano cose diverse, non la stessa cosa ruotata di
  poco.

**Non-Goals:**
- Un configuratore o un visualizzatore con misurazione interattiva.
- Animazioni di montaggio.

## Decisions

- **Le quote si disegnano in OpenSCAD, non si annotano sull'immagine.**
  Scriverle sul PNG a posteriori significa che il giorno in cui un
  parametro cambia la quota resta quella vecchia: una didascalia non si
  rigenera. Disegnate nel modello, seguono i parametri come tutto il
  resto.

- **Vista interattiva via STL + visualizzatore locale.** L'STL e' gia'
  prodotto e verificato da `check_case.py`; serve solo mostrarlo. Il
  visualizzatore va incluso nel sito come file locale.

- **L'interattivo non sostituisce le immagini statiche.** Un PNG si vede
  nel README, nei feed, con JavaScript disattivato e nei riassunti. Il
  visualizzatore e' un di piu', non il canale principale.

- **Le angolazioni sono scelte, non generate a giro d'orizzonte.** Per il
  contenitore: una tre quarti che mostra i vani, una dal basso che mostra
  il foro ottico e la superficie di incollaggio, una sul lato della
  USB-C. Dodici viste equidistanti riempiono la pagina e non aggiungono
  informazione.

## Risks / Trade-offs

- **Peso della pagina.** Un visualizzatore 3D porta con se' una libreria
  non piccola, e il sito oggi e' leggero. Va caricato solo nelle pagine
  che lo usano, e solo quando serve.

- **Il controllo delle immagini referenziate diventa piu' importante**:
  piu' file significa piu' modi di pubblicarne uno rotto. Il controllo
  esistente copre sito e README e va esteso ai nuovi nomi, che non sono
  piu' due o tre.

- **Tempo di render.** Ogni vista e' un render completo. Il numero di
  viste va tenuto basso per ragioni di tempo, non solo di leggibilita'.

## Open Questions

- **Quale visualizzatore**, e a che costo in byte: va scelto verificando
  che funzioni offline e senza CDN, non solo che esista.
