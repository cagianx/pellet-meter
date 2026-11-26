// Contenitore del pellet-meter.
//
// Due pezzi: scatola e coperchio. Sta SOPRA il coperchio della tramoggia;
// dentro il serbatoio sporge solo il cono di misura del sensore, che guarda
// in basso attraverso il fondo.
//
// Tutte le quote sono parametri. Quelle dei componenti vengono dai
// datasheet e NON sono state misurate sull'hardware: vedi la tabella
// "da rimisurare" piu' sotto.
//
//   openscad -o out/case.stl case.scad              // la sola scatola
//   openscad -o out/case.stl -D pezzo=\"coperchio\" case.scad
//   openscad -o out/case.stl -D pezzo=\"entrambi\" case.scad

// Cosa generare: "scatola", "coperchio", "entrambi" (affiancati, per il
// render) o "sezione" (taglio, per controllare gli interni).
pezzo = "entrambi";

// ---------------------------------------------------------------------------
// Componenti
// ---------------------------------------------------------------------------
// [larghezza, profondita', altezza] in mm, ingombro massimo compresi i
// componenti saldati sopra.
//
// DA RIMISURARE sull'esemplare reale, e perche':
//
//   scheda    il 21 x 17,5 e' da datasheet ed e' affidabile, ma l'altezza
//             dipende da come sono saldati gli header sulla millefori
//   batteria  le celle 603048 hanno tolleranze generose e spesso il
//             cartoncino e il nastro aggiungono mezzo millimetro per lato
//   sensore   l'ingombro del breakout VL53L1X cambia tra produttori, e con
//             esso la posizione della finestra ottica rispetto ai fori

scheda = [21.0, 17.5, 4.0];     // Seeed XIAO ESP32C6
batteria = [48.0, 30.0, 6.0];   // LiPo 603048, ~1000 mAh
sensore = [25.0, 13.0, 4.0];    // breakout VL53L1X, stima generosa

// Posizione della finestra ottica sul breakout, dal suo angolo inferiore
// sinistro. Anche questa cambia tra produttori.
finestra_ottica = [12.5, 6.5];
finestra_diametro = 4.5;        // apertura del sensore sulla scheda

// Connettore USB-C sulla scheda: larghezza, altezza e quota del centro dal
// piano della scheda.
usb = [9.0, 3.2];
usb_altezza_dal_piano = 1.6;

// ---------------------------------------------------------------------------
// Stampa
// ---------------------------------------------------------------------------

parete = 2.0;        // pareti verticali
fondo = 2.0;         // fondo della scatola
coperchio_sp = 2.0;  // spessore del coperchio

// Tolleranza di accoppiamento. E' l'unico numero da toccare se il
// coperchio entra duro o balla: il ritiro cambia con stampante e
// materiale, e non ha senso inseguirlo spargendo costanti nel modello.
gioco = 0.3;

labbro = 4.0;        // quanto il coperchio scende dentro la scatola
labbro_sp = 0.8;     // spessore del labbro
raggio = 3.0;        // raccordo verticale degli spigoli

// Aria attorno ai componenti, per infilarli senza forzare.
aria = 0.8;

// ---------------------------------------------------------------------------
// Vincoli di montaggio
// ---------------------------------------------------------------------------
// Non cambiano la geometria del pezzo: servono a controllare che il
// modello sia compatibile con l'installazione, e vengono stampati a
// fine render.

// Quanto deve stare la finestra ottica sopra il livello massimo del
// pellet. Sotto i 40 mm il VL53L1X non misura.
distanza_minima_pellet = 50;

// Spazio da lasciare libero verso coclea e microinterruttore di sicurezza
// del coperchio: il contenitore non deve entrarci dentro.
franco_coclea = 20;

// Angolo del cono di misura. Il VL53L1X arriva a 27 gradi; l'apertura nel
// fondo va svasata di conseguenza, altrimenti il bordo del foro entra nel
// fascio e il sensore misura la propria scatola.
fov = 27;

// ---------------------------------------------------------------------------
// Geometria derivata — da qui in giu' non ci sono numeri da cambiare
// ---------------------------------------------------------------------------

divisorio = 1.6;  // parete tra vano batteria e vano elettronica

// Vano batteria e vano elettronica stanno affiancati lungo Y.
// Nel vano elettronica, scheda e sensore stanno affiancati lungo X.
vano_elettronica = [
    scheda.x + aria + 3 + sensore.x + aria,
    max(scheda.y, sensore.y) + aria,
    max(scheda.z, sensore.z) + aria
];

vano_batteria = [batteria.x + aria, batteria.y + aria, batteria.z + aria];

interno = [
    max(vano_batteria.x, vano_elettronica.x),
    vano_batteria.y + divisorio + vano_elettronica.y,
    max(vano_batteria.z, vano_elettronica.z)
];

esterno = [
    interno.x + 2 * parete,
    interno.y + 2 * parete,
    interno.z + fondo + coperchio_sp
];

// Origine del vano elettronica, in coordinate interne.
el_x = 0;
el_y = vano_batteria.y + divisorio;

// Centro della finestra ottica, in coordinate interne. Il sensore e'
// appoggiato a destra nel vano elettronica.
sensore_x = vano_elettronica.x - sensore.x - aria / 2;
ottica = [
    el_x + sensore_x + finestra_ottica.x,
    el_y + aria / 2 + finestra_ottica.y
];

// Svaso del foro ottico: il cono si allarga scendendo verso il pellet.
svaso = fondo * tan(fov / 2);

// ---------------------------------------------------------------------------
// Pezzi
// ---------------------------------------------------------------------------

module guscio(dim, r) {
    // Prisma con spigoli verticali raccordati.
    hull() {
        for (x = [r, dim.x - r], y = [r, dim.y - r])
            translate([x, y, 0]) cylinder(h = dim.z, r = r, $fn = 32);
    }
}

// Altezza della sola scatola: il coperchio completa l'altezza esterna
// appoggiandosi in cima alle pareti, non sommandosi ad esse.
altezza_scatola = esterno.z - coperchio_sp;

// Quanto la battuta scava la faccia interna della parete.
battuta = labbro_sp + gioco;

module scatola() {
    difference() {
        guscio([esterno.x, esterno.y, altezza_scatola], raggio);

        // Cavita' interna
        translate([parete, parete, fondo])
            guscio([interno.x, interno.y, interno.z + 1],
                   max(0.1, raggio - parete));

        // Battuta del labbro: scava la faccia interna delle pareti negli
        // ultimi millimetri in alto. Il labbro entra qui dentro, non nello
        // spazio dei componenti: un labbro pieno schiaccerebbe la batteria.
        translate([parete - battuta, parete - battuta, altezza_scatola - labbro])
            guscio([interno.x + 2 * battuta, interno.y + 2 * battuta, labbro + 1],
                   max(0.1, raggio - parete + battuta));

        // Apertura ottica, svasata verso il basso.
        translate([parete + ottica.x, parete + ottica.y, -0.1])
            cylinder(h = fondo + 0.2,
                     r1 = finestra_diametro / 2 + svaso,
                     r2 = finestra_diametro / 2,
                     $fn = 48);

        // Apertura USB-C sulla parete corta, all'altezza del connettore.
        translate([-1,
                   parete + el_y + aria / 2 + scheda.y / 2 - usb.x / 2,
                   fondo + usb_altezza_dal_piano])
            cube([parete + 2, usb.x, usb.y + gioco]);
    }

    // Divisorio tra i due vani. Non arriva in cima: lascia passare il
    // filo della batteria senza doverci fare un foro.
    translate([parete, parete + vano_batteria.y, fondo])
        cube([interno.x, divisorio, interno.z * 0.6]);
}

module coperchio() {
    // Piastra piena...
    guscio([esterno.x, esterno.y, coperchio_sp], raggio);

    // ...piu' un labbro ad anello che scende nella battuta. E' cavo: la
    // faccia interna resta allineata a quella della cavita', cosi' non
    // ruba spazio ai componenti.
    translate([parete - battuta + gioco / 2, parete - battuta + gioco / 2, -labbro])
        difference() {
            guscio([interno.x + 2 * battuta - gioco,
                    interno.y + 2 * battuta - gioco, labbro],
                   max(0.1, raggio - parete + battuta));
            translate([labbro_sp, labbro_sp, -1])
                guscio([interno.x + 2 * battuta - gioco - 2 * labbro_sp,
                        interno.y + 2 * battuta - gioco - 2 * labbro_sp,
                        labbro + 2],
                       max(0.1, raggio - parete + battuta - labbro_sp));
        }
}

// ---------------------------------------------------------------------------
// Uscita
// ---------------------------------------------------------------------------

if (pezzo == "scatola") {
    scatola();
} else if (pezzo == "coperchio") {
    coperchio();
} else if (pezzo == "sezione") {
    difference() {
        scatola();
        translate([-1, esterno.y / 2, -1])
            cube([esterno.x + 2, esterno.y, esterno.z + 2]);
    }
} else {
    scatola();
    translate([0, esterno.y + 6, labbro]) coperchio();
}

// ---------------------------------------------------------------------------
// Quote dichiarate
// ---------------------------------------------------------------------------
// Vengono rilette da tools/check_case.py, che le confronta con il solido
// davvero generato: un parametro cambiato senza che la geometria lo segua
// e' un errore che non si vede guardando il render.

echo(str("QUOTE esterno=", esterno.x, "x", esterno.y, "x", esterno.z));
echo(str("QUOTE interno=", interno.x, "x", interno.y, "x", interno.z));
echo(str("QUOTE ottica=", ottica.x, ",", ottica.y));
echo(str("VINCOLO distanza_minima_pellet=", distanza_minima_pellet));
echo(str("VINCOLO franco_coclea=", franco_coclea));
