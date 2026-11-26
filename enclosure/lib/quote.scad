// Quote per i render: linea con frecce, linee di richiamo ed etichetta.
//
// Il valore NON si passa a mano. Lo calcola il modulo dalla distanza fra i
// due punti indicati, che a loro volta si ricavano dai parametri del pezzo.
// E' il motivo per cui le quote stanno nel modello e non sono didascalie
// scritte sull'immagine: una didascalia non si rigenera, e il giorno in cui
// un parametro cambia resta li' a dichiarare la misura di ieri.
//
// Il file sta in lib/ e non in enclosure/ apposta: tools/render.sh
// renderizza ogni .scad che trova direttamente in enclosure/, e una
// libreria di soli moduli darebbe una scena vuota — che adesso non passa
// nemmeno i controlli, visto che un render senza pezzo e' un errore.
//
// Unita': mm. Le misure si scrivono con la virgola, come nel resto della
// documentazione.

// ---------------------------------------------------------------------------
// Aspetto — un solo posto da toccare se le quote risultano piccole o pesanti
// ---------------------------------------------------------------------------

quota_testo = 3.6;      // altezza dei caratteri
quota_tratto = 0.45;    // spessore di linee e frecce
quota_punta = 2.4;      // lunghezza della punta della freccia
quota_rilievo = 0.4;    // spessore dell'estrusione: le quote sono solidi
quota_unita = " mm";    // sull'immagine la quota deve bastare a se' stessa

// Serve solo nell'anteprima della GUI (F5): il render CGAL che pubblica le
// immagini (F6, --render) ignora color(). Nel render le quote si leggono
// perche' stanno fuori dalla sagoma del pezzo, non perche' sono colorate.
quota_colore = "#1b3a4b";

// ---------------------------------------------------------------------------
// Funzioni di servizio
// ---------------------------------------------------------------------------

function _versore(v) = v / norm(v);

// str(54.6) da' "54.6": in italiano la misura si scrive "54,6". chr() di una
// lista di codici ricompone la stringa carattere per carattere.
function _virgola(s) =
    chr([for (i = [0 : len(s) - 1]) s[i] == "." ? ord(",") : ord(s[i])]);

// Un decimale: sotto il decimo di millimetro nessuna stampante 3D arriva, e
// le cifre in piu' rendono la quota illeggibile nel render.
function misura(v) = _virgola(str(round(v * 10) / 10));

// ---------------------------------------------------------------------------
// Quota lineare
// ---------------------------------------------------------------------------
//
//   da, a     i due punti SUL PEZZO fra cui si misura
//   verso     da che parte guarda il testo (la normale del piano di quota);
//             va scelto in base alla camera della vista, altrimenti il
//             numero si legge di taglio o a rovescio
//   scosto    quanto la linea di quota sta staccata dal pezzo
//   lato      +1 / -1: da quale dei due fianchi esce la quota
//   testo     solo per le quote che non misurano una distanza (raro):
//             lasciato indefinito, il valore viene dalla geometria
//
// Il sistema di riferimento locale e' destrorso per costruzione (x lungo la
// quota, z verso l'osservatore, y = z × x), quindi il testo non esce mai
// specchiato.

module quota(da, a, verso, scosto = 6, lato = 1, testo = undef,
             h = quota_testo) {
    lunghezza = norm(a - da);
    ex = _versore(a - da);
    // Componente di 'verso' perpendicolare alla quota: se chi chiama passa
    // una direzione storta, la quota resta comunque piana.
    ez = _versore(verso - ex * (verso * ex));
    ey = cross(ez, ex);

    // Posizione della linea di quota e dell'etichetta nel piano locale.
    y_linea = lato * scosto;
    y_testo = y_linea + lato * h * 0.75;

    color(quota_colore)
    multmatrix([[ex.x, ey.x, ez.x, da.x],
                [ex.y, ey.y, ez.y, da.y],
                [ex.z, ey.z, ez.z, da.z],
                [0, 0, 0, 1]]) {

        // Linea di quota. Le punte toccano le linee di richiamo e il corpo
        // della freccia sta dentro la quota, come su un disegno tecnico.
        translate([0, y_linea, 0]) {
            _segmento([0, 0], [lunghezza, 0]);
            _freccia([0, 0], 0);
            _freccia([lunghezza, 0], 180);
        }

        // Linee di richiamo: dal pezzo fino a poco oltre la linea di quota,
        // con un filo d'aria sul pezzo perche' si distinguano dallo spigolo.
        for (x = [0, lunghezza])
            _segmento([x, lato * 0.8], [x, y_linea + lato * 1.2]);

        // Etichetta. valign="baseline" la appoggia alla linea invece di
        // centrarla sopra: con "center" il numero tocca la quota.
        translate([lunghezza / 2, lato > 0 ? y_testo : y_testo - h, 0])
            linear_extrude(quota_rilievo)
                text(testo == undef ? str(misura(lunghezza), quota_unita)
                                    : testo,
                     size = h, halign = "center", valign = "baseline",
                     $fn = 24);
    }
}

// Segmento piatto nel piano locale XY.
module _segmento(p0, p1) {
    d = p1 - p0;
    translate([p0.x, p0.y, 0])
        rotate([0, 0, atan2(d.y, d.x)])
            translate([0, -quota_tratto / 2, 0])
                cube([norm(d), quota_tratto, quota_rilievo]);
}

// Punta di freccia piatta, nel piano locale XY, orientata di 'ang' gradi.
module _freccia(p, ang) {
    translate([p.x, p.y, 0]) rotate([0, 0, ang])
        linear_extrude(quota_rilievo)
            polygon([[0, 0],
                     [quota_punta, quota_punta * 0.28],
                     [quota_punta, -quota_punta * 0.28]]);
}
