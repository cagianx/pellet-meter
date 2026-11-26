---
title: "Contenitore 3D"
description: "Involucro parametrico in OpenSCAD: quote, tolleranze e cosa va rimisurato."
---

# Contenitore 3D

Modello parametrico in `enclosure/case.scad`. Due pezzi — scatola e
coperchio — da incollare **sotto** il coperchio della tramoggia, con
biadesivo o velcro: niente viti nella lamiera.

<img src="/assets/render/case.png" alt="Render del contenitore: scatola con due vani e coperchio"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

:::warning
**Le quote dei componenti vengono dai datasheet, non da una misura.** Il
primo esemplare stampato serve a verificare gli accoppiamenti, non a essere
installato. Cosa rimisurare e perche' e' nella tabella qui sotto.
:::

## Si monta capovolto, e leggendo il modello non si vede

E' la cosa da sapere prima di tutte le altre, perche' il modello non la
dice: **il contenitore in opera sta sottosopra rispetto a come e'
disegnato.** La faccia che nel file sta in basso — il fondo, quella che
appoggia sul piano di stampa — e' la faccia che si incolla al coperchio
della tramoggia. Il coperchio della scatola, che nel file sta in cima,
in opera guarda il pellet.

Da questo verso discende tutto il resto di questa pagina:

- il **fondo deve restare piano e continuo**, perche' e' la superficie di
  incollaggio, e la sua area deve bastare a reggere il peso;
- il **coperchio deve restare chiuso** senza contare sull'attrito: a
  testa in giu', se si apre, la batteria cade nel pellet;
- la **USB-C guarda l'interno della tramoggia**, dove c'e' polvere di
  legno, che e' abrasiva e igroscopica: va tappata.

:::warning
**L'apertura ottica e' nel fondo, cioe' nella faccia che si incolla.**
Nel verso di montaggio appena descritto guarda il coperchio della
tramoggia, non il pellet: cosi' com'e' il sensore non misura niente.
Spostare la finestra ottica sulla faccia che guarda il pellet e'
geometria nuova — tocca anche il verso in cui il breakout e' montato — e
va fatta con un change dedicato, non di straforo. Finche' non e' fatta,
il contenitore e' montabile ma non misura.
:::

## Com'e' fatto

Vano batteria e vano elettronica sono affiancati e separati da un divisorio
che **non arriva in cima**: il filo della batteria passa sopra, senza doverci
ricavare un foro.

Nel vano elettronica la scheda sta da un lato e il breakout del sensore
dall'altro. L'apertura USB-C e' sulla parete corta, all'altezza del
connettore.

Quote che ne risultano con i parametri di partenza:

| | mm |
|---|---|
| Ingombro esterno | 54,6 × 54,7 × 10,8 |
| Cavita' interna | 50,6 × 50,7 × 6,8 |
| Centro della finestra ottica | (37,7, 39,3) dal bordo interno |
| Ingombro sul piatto della stampante | 71,1 × 54,7 |
| Area della faccia di incollaggio | 2955 mm² (minimo richiesto 1200) |

L'ultima riga di ingombro non e' un errore: la scatola **occupa 71,1 mm
sul piatto** perche' il tappo della USB-C si stampa parcheggiato di
fianco, attaccato al suo cordino. In opera il contenitore resta largo
54,6.

## Il foro ottico e' svasato apposta

Il VL53L1X ha un cono di misura che arriva a **27°**. Un foro cilindrico
nello spessore del fondo intercetterebbe il bordo del fascio, e il sensore
finirebbe per misurare la propria scatola invece del pellet.

Per questo l'apertura e' **conica**, e si allarga verso l'esterno di
`fondo × tan(fov/2)` per lato. Cambiando lo spessore del fondo o
l'angolo, lo svaso si ricalcola da solo.

## Il tappo della USB-C non si puo' perdere

La USB-C guarda l'interno della tramoggia. Un connettore aperto in mezzo
alla polvere di pellet si sporca, e quella polvere e' abrasiva e
igroscopica.

Il tappo e' **stampato insieme alla scatola** e resta legato da un
cordino di 10 × 2,4 × 0,6 mm, che fa da cerniera viva. Un tappo separato,
dentro una tramoggia, e' un tappo perso al primo smontaggio.

Si stampa **parcheggiato di fianco alla scatola**, con la flangia
appoggiata al piano e la spina verso l'alto: in quel verso ogni strato e'
piu' piccolo del precedente, quindi non serve supporto. Per usarlo si
solleva il cordino, e il tappo si ritrova a puntare la parete.

:::note
La cerniera viva si rompe a flessioni ripetute, soprattutto in PLA. E'
un compromesso accettato: il tappo si apre di rado e il pezzo si
ristampa. In PETG dura di piu'.
:::

## Quanto biadesivo serve, in numeri

"Abbastanza biadesivo" non vuol dire niente, quindi l'area minima e'
calcolata e verificata:

| Parametro | Valore | Da dove viene |
|---|---|---|
| `peso_stimato` | 60 g | scheda ~5, cella LiPo ~20, breakout ~3, stampa ~30 |
| `adesivo_portata` | 20 g/cm² | valore prudente per schiuma biadesiva su una superficie stampata |
| `incollaggio_sicurezza` | 4 | a testa in giu' il carico e' di trazione e pelata, il caso peggiore |

Da qui l'area minima: 60 × 4 ÷ 20 = 12 cm², cioe' **1200 mm²**. Il fondo
ne offre **2955**, al netto dell'apertura ottica. Il margine e' ampio di
proposito: il contenitore puo' crescere parecchio prima che
l'incollaggio diventi il vincolo, e se cresce troppo `check_case.py` lo
dice.

La portata del biadesivo e' volutamente bassa rispetto alle schede
tecniche. Un nastro VHB dichiara numeri molto piu' alti, ma su un carico
permanente, a caldo, su una superficie stampata che non e' mai davvero
piana, i massimi di catalogo non si inseguono.

:::warning
**Il calore e' il limite vero, e non e' del modello.** Il coperchio di
una tramoggia puo' scaldarsi. Il PLA inizia a cedere intorno ai **60 °C**
e il biadesivo perde presa ben prima di strapparsi: il contenitore non si
stacca di colpo, scivola. Se il coperchio scalda, si stampa in **PETG** e
si sceglie un biadesivo dichiarato per alte temperature — e in ogni caso
la cella LiPo non va tenuta vicino a superfici calde: sopra i ~45 °C non
va nemmeno caricata.
:::

## Cosa tiene chiuso il coperchio

A testa in giu' l'attrito del labbro non basta, e il modo di guastarsi e'
brutto: il coperchio si apre e la batteria finisce nel pellet.

Due **dentini** sporgono dalla battuta della scatola verso l'interno, e
entrano in due **finestre** ricavate nel labbro del coperchio, una per
parete lunga. Il dentino e' un cuneo: pieno in basso, nullo in cima.
Scendendo, il labbro ci scivola sopra, si flette, e alla fine scatta
dentro la finestra; per risalire deve flettersi di nuovo, ed e' questo
che lo trattiene.

La sporgenza del dentino **non e' una seconda tolleranza**: vale
`2 × gioco`, cioe' 0,6 mm con `gioco = 0,3`. Il labbro corre a `gioco/2`
dalla battuta, quindi la presa utile e' 0,45 mm. Resta un numero solo da
tarare, come per l'accoppiamento del labbro.

Una chiusura che tiene va anche aperta: sul bordo superiore, dalla parte
opposta alla USB-C, c'e' una **tacca** di 8 × 1,5 mm. Sotto al coperchio
resta una fessura in cui infilare un'unghia e fare leva — senza
attrezzi, che e' il punto.

:::note
**Il labbro chiudeva la USB-C, e nessuno se n'era accorto.** La battuta
assottiglia la parete esattamente nei millimetri in cui sta il
connettore, e il labbro del coperchio ci passava davanti: con il
coperchio montato non sarebbe entrato ne' il cavo ne' la spina del
tappo. Il modello ora ritaglia quella luce nel labbro. E' il tipo di
difetto che non si vede guardando un pezzo alla volta — per questo il
controllo ora chiude i due pezzi e verifica che la loro intersezione sia
vuota.
:::

## Parametri

Stanno tutti in testa al file, raggruppati. I tre gruppi che si toccano
davvero:

| Gruppo | Cosa contiene |
|---|---|
| Componenti | ingombri di scheda, batteria e breakout, posizione della finestra ottica, quote del connettore USB-C |
| Stampa | spessori di pareti, fondo e coperchio; `gioco`; profondita' e spessore del labbro; raggio degli spigoli; tappo, cordino, dentini e tacca |
| Vincoli di montaggio | distanza minima dal pellet, franco verso coclea e microinterruttore, angolo del cono, peso stimato e portata del biadesivo |

```bash
# dalla cartella enclosure/
openscad -o out/case.stl case.scad                      # scatola e coperchio
openscad -o out/box.stl  -D 'pezzo="scatola"'   case.scad
openscad -o out/lid.stl  -D 'pezzo="coperchio"' case.scad
openscad -o out/sez.stl  -D 'pezzo="sezione"'   case.scad   # taglio, per gli interni
```

C'e' un quinto valore di `pezzo`, `"interferenza"`, che non e' un pezzo
da stampare ma un controllo: emette l'intersezione fra scatola e
coperchio chiusi, che deve risultare **vuota**. Lo usa `check_case.py`.

### Tolleranza: si cambia **un** numero

`gioco = 0.3` e' l'unico parametro da toccare se il coperchio entra duro o
balla. Il ritiro cambia con stampante e materiale, e inseguirlo spargendo
costanti nella geometria e' il modo di non riuscire piu' a correggerlo.

Indicativamente: 0,2 mm con una stampante ben tarata in PLA, 0,3 come
partenza prudente, 0,4 con PETG, che tende a spanciare.

### Cosa va rimisurato sull'esemplare reale

| Parametro | Perche' |
|---|---|
| `scheda` | i 21 × 17,5 mm da datasheet sono affidabili, l'**altezza** no: dipende da come sono saldati gli header sulla millefori |
| `batteria` | le celle 603048 hanno tolleranze generose, e cartoncino e nastro aggiungono spesso mezzo millimetro per lato |
| `sensore` e `finestra_ottica` | l'ingombro del breakout VL53L1X cambia tra produttori, e con esso la posizione della finestra rispetto ai fori |

## Come si verifica

Il render che non fallisce dice solo che il file e' sintatticamente valido.
Non dice se il solido ha le quote che il modello **afferma** di avere: basta
un parametro usato in un posto e dimenticato in un altro.

```bash
# dalla radice del repo
python3 tools/check_case.py
```

Il controllo confronta le quote dichiarate da `case.scad` con `echo()` e
il solido davvero prodotto. Quello che guarda:

| Controllo | Come fallisce |
|---|---|
| ingombri di scatola e coperchio | un parametro usato in un posto e dimenticato in un altro |
| finestra ottica dentro il fondo | il sensore finisce fuori dal pezzo |
| area di incollaggio ≥ minimo dal peso | il contenitore ingrassa e il biadesivo non regge piu' |
| area del piano d'appoggio dichiarata = misurata | qualcuno mette uno zoccolo sul fondo e la faccia non e' piu' incollabile |
| la scatola e' **un solo** solido connesso | il cordino non tocca la parete e il tappo esce staccato |
| intersezione dei due pezzi chiusi vuota | un dentino non cade nella sua finestra e il coperchio non chiude |
| il solido reagisce al cambio di parametro | c'e' un numero scritto a mano al posto del parametro |

Le ultime quattro righe misurano il **solido**, non i parametri: area
delle facce sul piano piu' basso, componenti connesse dei triangoli dello
STL, intersezione dei due pezzi nella posizione di chiusura. Sono le cose
che un bounding box non vede e che guardando il render non saltano
all'occhio.

Un controllo che nessuno ha mai visto scattare non e' una verifica, e'
una decorazione. Per questo `check_case.py` accetta dei `-D` e li passa a
tutti i render:

```bash
python3 tools/check_case.py -D peso_stimato=400
#   NO  area 2955 mm2, minimo per il peso 8000 mm2: mancano 5045 mm2

python3 tools/check_case.py -D 'cordino=[10,0,0.6]'
#   NO  la scatola e' un solo solido: 2 componente(i) connessa(e)

python3 tools/check_case.py -D dente_z=7.5
#   NO  scatola e coperchio chiusi non si compenetrano
```

:::note
Il controllo sui parametri verifica che il modello **reagisca**, non di
quanto.
Allungando la batteria di 12 mm il contenitore cresce di 10,2: con le quote
di partenza a comandare la lunghezza e' il vano elettronica (50,6 mm) e non
la batteria (48,8 mm). Pretendere la crescita esatta vorrebbe dire
riscrivere nel controllo la logica del modello, cioe' verificarlo con se
stesso.
:::

## Cosa resta fuori, deliberatamente

- **Tenuta stagna.** Il tappo serve a tenere fuori la polvere, non
  l'acqua, e il contenitore non e' sigillato da nessuna parte.
- **Viti e inserti filettati.** Aggiungono ferramenta a un pezzo che deve
  restare semplice da stampare e da iterare, e un filetto stampato si
  rompe prima del resto.
- **Resistenza al calore.** E' una proprieta' del materiale, non del
  modello: si sceglie stampando, e il limite e' scritto qui sopra.
- **Dove esattamente si incolla.** Il verso e' deciso — sotto il
  coperchio della tramoggia — ma il punto dipende dalla stufa. I vincoli
  restano parametri del modello: almeno 4–5 cm sopra il livello massimo
  del pellet, niente contatto con coclea e microinterruttore di
  sicurezza.

## Stato della CI

Il job `contenitore` del workflow `hardware` ora e' attivo: genera gli STL,
controlla che non siano vuoti ed esegue `check_case.py`. Il render PNG di
questa pagina lo produce `tools/render.sh`, nel workflow `docs`.
