// Il contenitore chiuso, con le quote d'ingombro.
//
// Le quote non sono scritte: vengono dalle variabili di case.scad, le
// stesse che il modello dichiara con echo("QUOTE ...") e che
// tools/check_case.py confronta col solido generato. Cambiare un parametro
// cambia il pezzo e l'immagine insieme.
//
// 'include' e non 'use': servono le variabili (esterno, altezza_scatola),
// e 'use' importa solo i moduli.

include <../case.scad>
include <../lib/quote.scad>

// In OpenSCAD l'ultima assegnazione nell'ambito vince e vale anche per le
// righe precedenti: riassegnare 'pezzo' qui decide cosa emette l'include di
// case.scad. Serve la sola scatola, perche' il coperchio lo si rimette al
// suo posto qui sotto invece che affiancato.
pezzo = "scatola";

// Assieme chiuso: il coperchio appoggia in cima alle pareti, e l'altezza
// totale torna a essere esterno.z — la quota che si vuole mostrare.
translate([0, 0, altezza_scatola]) coperchio();

// Le tre quote d'ingombro. 'verso' e' scelto per la camera della vista
// (tre quarti da davanti-destra): il testo deve guardare l'osservatore,
// altrimenti si legge di taglio.
quota([0, 0, 0], [esterno.x, 0, 0], verso = [0, 0, 1], scosto = 7, lato = -1);
quota([esterno.x, 0, 0], [esterno.x, esterno.y, 0],
      verso = [0, 0, 1], scosto = 7, lato = -1);
// L'altezza esce dallo spigolo verticale di sinistra: a destra incrocerebbe
// la quota della profondita'.
quota([0, 0, 0], [0, 0, esterno.z], verso = [0, -1, 0], scosto = 9, lato = 1);
