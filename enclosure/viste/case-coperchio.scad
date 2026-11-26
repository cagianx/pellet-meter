// Il coperchio visto da sotto: il labbro, le due finestre in cui entrano
// i dentini della battuta e la luce per la USB-C.
//
// E' la faccia che nessun'altra vista mostra, ed e' quella dove sta la
// ritenuta: dall'alto il coperchio e' una piastra liscia, e chi guarda
// solo le altre viste non ha modo di sapere che cosa lo tiene chiuso a
// testa in giu'.
//
// Il pezzo e' capovolto invece di essere guardato dal basso spostando la
// camera, per la stessa ragione di case-sotto.scad: la luce di OpenSCAD
// e' fissa nel mondo e viene dall'alto, e da sotto il pezzo esce una
// faccia uniformemente scura.
//
// 'use' e non 'include': qui servono solo i moduli, e con include il
// codice in coda a case.scad emetterebbe anche i pezzi diritti.

use <../case.scad>

rotate([180, 0, 0]) coperchio();
