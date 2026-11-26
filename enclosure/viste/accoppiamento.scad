// Verifica di accoppiamento fra la scheda e il contenitore.
//
// Non e' una vista da pubblicare: e' un modello di controllo, guidato da
// tools/check_fit.py, che risponde a una domanda sola — la scheda, con i
// suoi componenti, tocca il contenitore?
//
// Il modo di rispondere e' geometrico, non aritmetico: si intersecano il
// solido della scheda e quello del contenitore. Se l'intersezione e'
// vuota la scheda ci sta; se non lo e', il suo ingombro dice di quanto e
// dove. Un confronto fra numeri si fermerebbe all'involucro esterno e non
// vedrebbe ne' il divisorio fra i due vani ne' la battuta del coperchio.
//
//   use <../case.scad>   porta scatola() e coperchio() SENZA eseguire la
//                        geometria di primo livello di case.scad. Con
//                        include le due scatole finirebbero dentro
//                        l'intersezione e il risultato sarebbe senza senso.
//
// I numeri non stanno qui: li passa check_fit.py con -D, leggendoli dalle
// quote che case.scad dichiara con echo("QUOTE ...") e dal .kicad_pcb.
// Cosi' una quota che cambia nel contenitore si propaga da sola.

use <../case.scad>

pcb = "";                   // STL della scheda, componenti compresi
pcb_foro = [0, 0];          // centro del foro ottico, in coordinate STL
pcb_zmin = 0;               // quota piu' bassa dello STL (reofori compresi)
bersaglio = [0, 0];         // dove deve finire il foro, dentro il contenitore
appoggio = 0;               // quota interna del fondo
altezza_scatola = 0;        // da dove parte il coperchio

// Il breakout VL53L1X in KiCad e' solo un header a 6 pin: il corpo non
// c'e'. Lo si aggiunge qui come parallelepipedo, con le stesse quote che
// il contenitore usa per dimensionare il vano.
sensore_corpo = [25, 13, 4];
sensore_altezza = 8.5;      // header femmina sotto il breakout
pcb_spessore = 1.6;

mostra = "collisione";      // "collisione" oppure "assieme"

module scheda() {
    // kicad-cli esporta con la Y rovesciata rispetto al foglio: senza
    // questo specchio la scheda risulterebbe ribaltata, cioe' un'altra
    // scheda.
    translate([bersaglio.x - pcb_foro.x,
               bersaglio.y - pcb_foro.y,
               appoggio - pcb_zmin])
        union() {
            scale([1, -1, 1]) import(pcb);
            translate([pcb_foro.x - sensore_corpo.x / 2,
                       pcb_foro.y - sensore_corpo.y / 2,
                       pcb_spessore + sensore_altezza])
                cube(sensore_corpo);
        }
}

module contenitore() {
    scatola();
    translate([0, 0, altezza_scatola]) coperchio();
}

if (mostra == "assieme") {
    scheda();
    contenitore();
} else {
    intersection() {
        scheda();
        contenitore();
    }
}
