// Il contenitore visto dal fondo: foro ottico svasato e superficie che
// appoggia sul coperchio della tramoggia.
//
// Il pezzo e' capovolto invece di essere guardato dal basso spostando la
// camera. La luce di OpenSCAD e' fissa nel mondo e viene dall'alto: una
// camera sotto il pezzo restituisce una faccia uniformemente scura, dove il
// foro ottico non si distingue. Capovolgere il pezzo e' anche il gesto che
// si fa davvero per guardargli il fondo.
//
// 'use' e non 'include': qui servono solo i moduli, e con include il codice
// in coda a case.scad emetterebbe anche il pezzo diritto, che non si puo'
// piu' ruotare.

use <../case.scad>

rotate([180, 0, 0]) scatola();
