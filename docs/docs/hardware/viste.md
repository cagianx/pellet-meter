---
title: "Viste e quote del contenitore"
description: "Le viste pubblicate del contenitore, la variante quotata e il modello da ruotare nel browser."
---

# Viste e quote del contenitore

Il pezzo e i suoi parametri sono descritti in
[Contenitore 3D](/hardware/contenitore/). Qui c'e' come lo si **guarda**: le
angolazioni pubblicate, la variante con le quote e il modello ruotabile.

Le immagini le produce `tools/render.sh`, la stessa pipeline che gira in CI.
Nessuna e' versionata: si rigenerano dal modello a ogni pubblicazione, e non
possono quindi descrivere una versione precedente del pezzo.

## Quattro angolazioni, non dodici

Una vista in piu' costa un render intero e, se non mostra niente di nuovo,
costringe solo a guardare due volte la stessa scatola. Queste quattro sono
scelte perche' ognuna mostra qualcosa che le altre nascondono.

**Tre quarti dall'alto** — i due vani, il divisorio che non arriva in cima,
il labbro del coperchio e il tappo della USB-C parcheggiato di fianco alla
scatola, legato dal suo cordino.

<img src="/assets/render/case.png" alt="Contenitore in tre quarti: scatola con i due vani e coperchio affiancato"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

**Dal fondo** — l'apertura ottica svasata e la **faccia che si incolla**
sotto il coperchio della tramoggia: dev'essere piana e continua, e qui si
vede che lo e'. Il pezzo e' capovolto, non guardato dal basso, per il
motivo spiegato in fondo alla pagina: la luce di OpenSCAD non segue la
camera. Capovolto, pero', e' anche il verso in cui il contenitore viene
montato davvero.

<img src="/assets/render/case-sotto.png" alt="Contenitore capovolto: fondo con il foro ottico svasato"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

**Lato USB-C** — l'apertura sulla parete corta e il tappo che la chiude,
che dall'alto si intuiscono appena. Il tappo si stampa in piedi, con la
flangia sul piano e la spina verso l'alto.

<img src="/assets/render/case-usb.png" alt="Contenitore dal lato dell'apertura USB-C, con il tappo parcheggiato"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

**Coperchio da sotto** — le due finestre in cui entrano i dentini della
battuta e la luce per la USB-C. Dall'alto il coperchio e' una piastra
liscia: senza questa vista non si vedrebbe che cosa lo tiene chiuso a
testa in giu'.

<img src="/assets/render/case-coperchio.png" alt="Coperchio capovolto: labbro con le finestre dei dentini e la luce per la USB-C"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

## Le quote stanno nel modello, non sull'immagine

<img src="/assets/render/case-quote.png" alt="Contenitore chiuso con le quote d'ingombro"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

Scrivere le misure sul PNG a posteriori — o in una didascalia sotto
l'immagine — sembra la strada corta. Non lo e': **una didascalia non si
rigenera**. Il giorno in cui qualcuno allarga il vano batteria, il render
cambia e il numero resta quello di ieri, senza che niente fallisca. Una
quota sbagliata e' peggio di una quota assente, perche' chi la legge non ha
motivo di dubitarne.

Le quote di questa immagine sono disegnate dentro OpenSCAD, in
`enclosure/viste/case-quote.scad`, e il valore **non viene mai scritto a
mano**: il modulo `quota()` misura la distanza fra i due punti che riceve, e
quei punti sono le variabili di `case.scad`. Cambiare un parametro cambia il
solido, i punti, il numero e l'immagine nello stesso passaggio.

E' lo stesso principio di `tools/check_case.py`, che confronta le quote
dichiarate con il solido davvero generato: in questo progetto un numero
pubblicato deve avere una sola sorgente, il modello.

:::note
Nel render le quote sono dello stesso colore del pezzo. Non e' una svista:
il render esatto di OpenSCAD (`--render`, cioe' F6) **ignora `color()`**, e
le quote si leggono perche' stanno fuori dalla sagoma. Il colore impostato
in `lib/quote.scad` serve solo all'anteprima della GUI.
:::

## Il modello da girare

<div data-stl-viewer style="background:#f7f7f7;border-radius:6px;padding:1rem">
  <p>
    Modello tridimensionale interattivo: servono JavaScript e WebGL.
    In alternativa si puo'
    <a href="/assets/render/case.stl">scaricare l'STL</a>
    e aprirlo in una slicer — e le immagini qui sopra restano sufficienti
    a capire forma e ingombro.
  </p>
</div>

Si trascina col mouse o col dito per ruotare, si usa la rotella per lo
zoom; con la tastiera, le quattro frecce. E' lo **stesso STL** che produce
la pipeline di render, non un'esportazione a parte: se il solido non si
chiude, qui si vede.

Il visualizzatore e' scritto su misura, WebGL senza librerie, e sta in
`docs/docs/assets/js/stl-viewer.js`.

| | |
|---|---|
| `stl-viewer.js` | 13 kB di sorgente commentato, **5 kB** compressi |
| `case.stl` | 71 kB, **15 kB** compressi |
| three.js, per confronto | oltre 600 kB di libreria minificata |

La scelta non e' nata dal peso ma dal vincolo: **il sito non dipende da
CDN**: una pagina che per mostrare un pezzo deve interrogare il server di
qualcun altro smette di funzionare quando quel server cambia idea. Una
libreria pronta andrebbe quindi copiata dentro il sito, e a quel punto
mantenere qualche centinaio di righe scritte qui costa meno che trascinarsi
mezzo megabyte di codice altrui per far girare una scatola. Lo script viene
caricato solo da questa pagina, non da tutto il sito.

## Come si aggiunge una vista

Le viste sono un elenco in `tools/render.sh`, una riga ciascuna:

```bash
vista case-usb enclosure/case.scad 80 250 p -D 'pezzo="scatola"'
#     nome     sorgente            ^  ^   ^  opzioni di openscad
#                       elevazione ┘  │   └ p = prospettica, o = ortogonale
#                              azimut ┘
```

Di scritto a mano ci sono **solo i due angoli**: posizione e distanza della
camera le ricalcolano `--autocenter` e `--viewall` sul pezzo vero, quindi
una quota che cambia non lascia il render tagliato o lontano.

- **elevazione**: 0 = dall'alto, 90 = di fianco, 180 = dal basso
- **azimut**: 0 = si guarda la parete `y = 0`, e crescendo si gira attorno
  al pezzo in senso antiorario

Un `.scad` che nessuna riga nomina viene renderizzato lo stesso, con
l'inquadratura automatica, e lo script lo segnala: meglio un render
generico che una pagina senza immagine.

## Trappole di OpenSCAD incontrate qui

### La luce di OpenSCAD non segue la camera

Mettere la camera sotto il pezzo per fotografarne il fondo **non
funziona**: la luce e' fissa nel mondo e viene dall'alto, quindi la faccia
inferiore esce di un colore piatto e uniforme, dove il foro ottico non si
distingue dal resto. Cambiare `--colorscheme` non aiuta: sono stati provati
tutti e sei, il risultato e' lo stesso in sei colori diversi.

La soluzione e' **capovolgere il pezzo** invece della camera, che poi e'
anche il gesto che si fa davvero per guardare sotto una scatola.

### `include` porta le variabili, `use` no

Per quotare serve leggere `esterno` e `altezza_scatola` da `case.scad`:
le importa `include`, non `use`. Ma `include` esegue anche il codice in
coda al file incluso, che **emette il pezzo**, e quella geometria non si
puo' piu' spostare ne' ruotare.

Da qui i tre file in `enclosure/viste/`, diversi apposta:

| File | Serve | Come |
|---|---|---|
| `case-quote.scad` | le variabili, per quotare | `include`, e il pezzo resta dov'e' |
| `case-sotto.scad` | ruotare la scatola | `use`, e la si richiama a mano |
| `case-coperchio.scad` | ruotare il coperchio | `use`, idem |

Con `include` c'e' un secondo appiglio utile: in OpenSCAD **l'ultima
assegnazione di una variabile nell'ambito vince**, anche sulle righe
precedenti. Riassegnare `pezzo` *dopo* l'include decide che cosa il file
incluso ha emesso.

### I font mancanti non fanno rumore

Se nel container non ci sono font installati, `text()` non disegna nulla.
OpenSCAD **non avvisa** — provato con un `fontconfig` senza cartelle di
font — ed esce con successo. Il risultato e' un render quotato con le
linee di quota e senza numeri: proprio l'immagine che questa pagina esiste
per evitare, e per di piu' con la CI verde.

Non essendoci un avviso da intercettare, `render.sh` chiede a OpenSCAD di
estrudere una riga di cifre e guarda se ne esce geometria, prima di
renderizzare le viste.

E' la stessa famiglia di guasti del PNG da zero byte e della scena vuota,
raccontati in [Come si verifica](/know-how/verifica/): il codice di uscita
di OpenSCAD non e' una fonte affidabile di verita'.

<!-- Percorso relativo alla pagina, non assoluto: docmd riscrive href e src
     di link e immagini in percorsi relativi al livello della pagina, ma non
     quelli dei tag <script>. Un "/assets/..." finirebbe fuori dalla
     sottocartella di GitHub Pages, e il visualizzatore non si caricherebbe
     piu'. Il controllo della CI risolve i riferimenti rispetto alla pagina
     che li contiene, proprio per accorgersi di questo. -->
<script src="../../assets/js/stl-viewer.js"></script>
