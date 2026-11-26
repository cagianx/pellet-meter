// Contenitore del pellet-meter.
//
// Due pezzi: scatola e coperchio. Si incolla SOTTO il coperchio della
// tramoggia, quindi in opera sta CAPOVOLTO rispetto a come e' disegnato
// qui: la faccia incollata e' il fondo, e il coperchio guarda il pellet.
// Leggendo il modello non si vede, ed e' il motivo per cui il fondo deve
// restare piano e il coperchio deve essere trattenuto da qualcosa che non
// sia l'attrito. Vedi docs/docs/hardware/contenitore.md.
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

// --- Tappo della USB-C ---
// In opera la USB-C guarda l'interno della tramoggia, e la polvere di
// pellet e' abrasiva e igroscopica. Il tappo e' stampato insieme alla
// scatola e resta legato da un cordino: un tappo separato, dentro una
// tramoggia, e' un tappo perso al primo smontaggio.

tappo_flangia = 1.2;       // piastrina che appoggia fuori sulla parete
tappo_bordo = 1.5;         // quanto la flangia sporge oltre il foro
cordino = [10.0, 2.4, 0.6];  // lunghezza, larghezza, spessore del filetto

// --- Ritenuta del coperchio ---
// A testa in giu' l'attrito del labbro non basta: se il coperchio si apre,
// la batteria cade nel pellet. Due dentini sulla battuta entrano in due
// finestre ricavate nel labbro.
//
// La sporgenza del dentino NON e' una seconda tolleranza: e' un multiplo
// di 'gioco'. Il labbro corre a gioco/2 dalla battuta, quindi la presa
// utile e' dente_sp - gioco/2.

dente_largh = 6.0;         // larghezza del dentino lungo la parete
dente_alt = 1.6;           // altezza dello scivolo d'invito
dente_sp = 2 * gioco;      // sporgenza verso l'interno

// Tacca per l'unghia sul bordo superiore: una chiusura che tiene deve
// anche potersi aprire a mano.
tacca = [8.0, 1.5];        // larghezza, profondita' sotto il bordo

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

// Peso stimato del dispositivo finito, in grammi: scheda ~5, cella LiPo
// 603048 ~20, breakout ~3, stampa ~30. Serve a rendere verificabile la
// tenuta dell'incollaggio: senza un numero, "abbastanza biadesivo" non
// vuol dire niente.
peso_stimato = 60;

// Quanto sopporta il biadesivo, in grammi per cm quadrato. Valore
// prudente per schiuma biadesiva su una superficie stampata, che non e'
// mai perfettamente piana: le schede tecniche danno molto di piu', ma su
// un carico permanente e a caldo non si inseguono i massimi.
adesivo_portata = 20;

// Fattore di sicurezza. A testa in giu' il carico e' di trazione e di
// pelata, non di taglio, ed e' il caso peggiore per un biadesivo.
incollaggio_sicurezza = 4;

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

// Apertura USB-C: misure del vuoto nella parete e posizione del suo
// centro. Foro e tappo si ricavano da qui, cosi' non possono scordarsi
// l'uno dell'altro.
usb_foro = [usb.x, usb.y + gioco];
usb_centro = [
    parete + el_y + aria / 2 + scheda.y / 2,
    fondo + usb_altezza_dal_piano + usb_foro.y / 2
];

// Ingombro della flangia del tappo, che sta fuori dalla parete.
tappo_flangia_dim = [usb_foro.x + 2 * tappo_bordo,
                     usb_foro.y + 2 * tappo_bordo];

// Quanto tappo e cordino sporgono oltre la parete x = 0 nel pezzo
// stampato. Il tappo e' parcheggiato sul piano di stampa, in piedi: cosi'
// ogni strato e' piu' piccolo del precedente e non serve supporto.
tappo_sporgenza = cordino.x + tappo_flangia_dim.y;

// Altezza della sola scatola: il coperchio completa l'altezza esterna
// appoggiandosi in cima alle pareti, non sommandosi ad esse.
altezza_scatola = esterno.z - coperchio_sp;

// Quanto la battuta scava la faccia interna della parete.
battuta = labbro_sp + gioco;

// Finestra nel labbro e dentino sulla battuta, in quota scatola. La
// finestra sta in mezzo all'altezza del labbro: toglierla all'estremita'
// libera lo spaccherebbe in due rebbi.
finestra_dente = [dente_largh + 2 * gioco, dente_alt + 2 * gioco];
finestra_z = altezza_scatola - labbro + (labbro - finestra_dente.y) / 2;
dente_z = finestra_z + gioco;

// Area di incollaggio: impronta esterna del fondo (prisma con spigoli
// raccordati) meno l'apertura ottica. Il minimo viene dal peso: se il
// contenitore o il peso cambiano, il confronto lo fa tools/check_case.py.
area_incollaggio = esterno.x * esterno.y - (4 - PI) * raggio * raggio
                   - PI * pow(finestra_diametro / 2 + svaso, 2);
area_incollaggio_minima =
    peso_stimato * incollaggio_sicurezza / adesivo_portata * 100;

// Impronta che tappo e cordino lasciano sul piano di stampa: stanno
// accanto alla scatola, non sul fondo. Serve a chi misura il piano z = 0
// del solido, che li trova insieme al fondo e deve sapere quanto vale
// ciascuno dei due pezzi.
area_tappo = tappo_flangia_dim.x * tappo_flangia_dim.y
             + cordino.x * cordino.y;
area_appoggio = area_incollaggio + area_tappo;

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

// Dentino a scatto. Cuneo pieno in basso e nullo in cima: stampato dal
// basso ogni strato e' piu' piccolo del precedente, quindi non serve
// supporto, e lo scivolo fa entrare il labbro senza forzare. Il gradino
// sta sotto, dove trattiene: quello si', ma e' uno sporto di dente_sp,
// che nessuna stampante fatica a ponteggiare.
//
// Occupa x in [0, dente_largh], sporge in +y, cresce verso il basso.
module dente() {
    rotate([90, 0, 90])
        linear_extrude(dente_largh)
            polygon([[0, 0], [dente_sp, 0], [0, dente_alt]]);
}

// Tappo della USB-C nella posizione in cui si usa: spina dentro il foro,
// flangia appoggiata fuori sulla parete. L'origine e' il centro del foro
// sulla faccia esterna x = 0, e la spina va verso +x.
module tappo() {
    // Spina: la sezione del foro meno il gioco, per la profondita' della
    // parete. Non entra oltre: dietro c'e' il connettore.
    translate([0, -(usb_foro.x - gioco) / 2, -(usb_foro.y - gioco) / 2])
        cube([parete, usb_foro.x - gioco, usb_foro.y - gioco]);

    // Flangia: chiude la fessura attorno alla spina e da' il bordo da
    // prendere con l'unghia per estrarre il tappo.
    translate([-tappo_flangia, -tappo_flangia_dim.x / 2,
               -tappo_flangia_dim.y / 2])
        cube([tappo_flangia, tappo_flangia_dim.x, tappo_flangia_dim.y]);
}

// Il tappo come viene stampato: in piedi sul piano, accanto alla parete,
// legato alla scatola dal cordino. La flangia appoggia sul piano e la
// spina guarda in alto; per usarlo si solleva il cordino e il tappo si
// ritrova a puntare verso la parete. Il cordino e' un nastro sottile che
// si piega in quel verso e fa da cerniera viva.
module tappo_parcheggiato() {
    // Cordino: parte dalla parete, al centro del foro, e corre sul piano.
    // Sborda di mezzo millimetro dentro la parete e dentro la flangia,
    // perche' l'unione sia solida e non un contatto fra due superfici
    // che si sfiorano. Lo sbordo sta dentro altra materia: non allunga
    // l'impronta, e il conto dell'area di appoggio resta esatto.
    translate([-cordino.x - 0.5, usb_centro.x - cordino.y / 2, 0])
        cube([cordino.x + 1.0, cordino.y, cordino.z]);

    // La rotazione porta l'asse della spina da +x a +z.
    translate([-cordino.x - tappo_flangia_dim.y / 2, usb_centro.x,
               tappo_flangia])
        rotate([0, -90, 0]) tappo();
}

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
                   usb_centro.x - usb_foro.x / 2,
                   usb_centro.y - usb_foro.y / 2])
            cube([parete + 2, usb_foro.x, usb_foro.y]);

        // Tacca per l'unghia: toglie un pezzetto di bordo sulla parete
        // opposta alla USB, cosi' sotto al coperchio resta una fessura in
        // cui infilare un'unghia e fare leva. Senza, una chiusura che
        // tiene a testa in giu' non si apre piu' senza attrezzi.
        translate([esterno.x - parete - 1, (esterno.y - tacca.x) / 2,
                   altezza_scatola - tacca.y])
            cube([parete + 2, tacca.x, tacca.y + 1]);
    }

    // Dentini sulla battuta delle due pareti lunghe. Sporgono verso
    // l'interno e si infilano nelle finestre del labbro: la ritenuta e'
    // meccanica, non affidata all'attrito.
    translate([(esterno.x - dente_largh) / 2, parete - battuta, dente_z])
        dente();
    translate([(esterno.x + dente_largh) / 2,
               esterno.y - parete + battuta, dente_z])
        rotate([0, 0, 180]) dente();

    // Tappo della USB-C, parcheggiato sul piano di stampa accanto alla
    // parete, piu' il cordino che lo tiene.
    tappo_parcheggiato();

    // Divisorio tra i due vani. Non arriva in cima: lascia passare il
    // filo della batteria senza doverci fare un foro.
    translate([parete, parete + vano_batteria.y, fondo])
        cube([interno.x, divisorio, interno.z * 0.6]);
}

module coperchio() {
    difference() {
        union() {
            // Piastra piena...
            guscio([esterno.x, esterno.y, coperchio_sp], raggio);

            // ...piu' un labbro ad anello che scende nella battuta. E'
            // cavo: la faccia interna resta allineata a quella della
            // cavita', cosi' non ruba spazio ai componenti.
            translate([parete - battuta + gioco / 2,
                       parete - battuta + gioco / 2, -labbro])
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

        // Finestre per i dentini della battuta, una per parete lunga.
        // Passano da parte a parte nel labbro: una tasca cieca in uno
        // spessore di labbro_sp non resterebbe spessore.
        for (y = [-1, esterno.y - 3 + 1])
            translate([(esterno.x - finestra_dente.x) / 2, y,
                       finestra_z - altezza_scatola])
                cube([finestra_dente.x, 3, finestra_dente.y]);

        // Luce per la USB-C. Il labbro corre proprio davanti all'apertura
        // nella parete — la battuta assottiglia la parete negli stessi
        // millimetri in cui sta il connettore — e senza questo taglio
        // chiuderebbe il foro: ne' il cavo ne' la spina del tappo
        // entrerebbero con il coperchio montato.
        translate([-1, usb_centro.x - usb_foro.x / 2 - gioco, -labbro - 1])
            cube([parete + 1 + gioco,
                  usb_foro.x + 2 * gioco,
                  labbro + 1 + usb_centro.y + usb_foro.y / 2
                  - altezza_scatola + gioco]);
    }
}

// ---------------------------------------------------------------------------
// Uscita
// ---------------------------------------------------------------------------

if (pezzo == "scatola") {
    scatola();
} else if (pezzo == "coperchio") {
    coperchio();
} else if (pezzo == "interferenza") {
    // Non e' un pezzo da stampare: e' un controllo. I due solidi nella
    // posizione di chiusura devono sfiorarsi e basta. Se l'intersezione
    // non e' vuota il coperchio non si chiude, ed e' cosi' che ci si
    // accorge che un dentino non cade dentro la sua finestra.
    // OpenSCAD, davanti a un risultato vuoto, si lamenta e non scrive il
    // file: qui quello e' l'esito buono. Lo legge tools/check_case.py.
    intersection() {
        scatola();
        translate([0, 0, altezza_scatola]) coperchio();
    }
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
echo(str("QUOTE tappo_sporgenza=", tappo_sporgenza));
echo(str("QUOTE area_incollaggio=", area_incollaggio));
echo(str("QUOTE area_incollaggio_minima=", area_incollaggio_minima));
echo(str("QUOTE area_appoggio=", area_appoggio));
echo(str("VINCOLO distanza_minima_pellet=", distanza_minima_pellet));
echo(str("VINCOLO franco_coclea=", franco_coclea));
