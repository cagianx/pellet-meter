---
title: "Contenitore 3D"
description: "Involucro parametrico in OpenSCAD: quote, tolleranze e cosa va rimisurato."
---

# Contenitore 3D

Modello parametrico in `enclosure/case.scad`. Due pezzi — scatola e
coperchio — che stanno **sopra** il coperchio della tramoggia: dentro il
serbatoio si affaccia solo il cono di misura del sensore, che guarda in
basso attraverso il fondo.

<img src="/assets/render/case.png" alt="Render del contenitore: scatola con due vani e coperchio"
     style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">

:::warning
**Le quote dei componenti vengono dai datasheet, non da una misura.** Il
primo esemplare stampato serve a verificare gli accoppiamenti, non a essere
installato. Cosa rimisurare e perche' e' nella tabella qui sotto.
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

## Il foro ottico e' svasato apposta

Il VL53L1X ha un cono di misura che arriva a **27°**. Un foro cilindrico
nello spessore del fondo intercetterebbe il bordo del fascio, e il sensore
finirebbe per misurare la propria scatola invece del pellet.

Per questo l'apertura e' **conica**, e si allarga scendendo verso il pellet
di `fondo × tan(fov/2)` per lato. Cambiando lo spessore del fondo o
l'angolo, lo svaso si ricalcola da solo.

## Parametri

Stanno tutti in testa al file, raggruppati. I tre gruppi che si toccano
davvero:

| Gruppo | Cosa contiene |
|---|---|
| Componenti | ingombri di scheda, batteria e breakout, posizione della finestra ottica, quote del connettore USB-C |
| Stampa | spessori di pareti, fondo e coperchio; `gioco`; profondita' e spessore del labbro; raggio degli spigoli |
| Vincoli di montaggio | distanza minima dal pellet, franco verso coclea e microinterruttore, angolo del cono |

```bash
# dalla cartella enclosure/
openscad -o out/case.stl case.scad                      # scatola e coperchio
openscad -o out/box.stl  -D 'pezzo="scatola"'   case.scad
openscad -o out/lid.stl  -D 'pezzo="coperchio"' case.scad
openscad -o out/sez.stl  -D 'pezzo="sezione"'   case.scad   # taglio, per gli interni
```

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

Il controllo confronta tre cose: le quote dichiarate da `case.scad` con
`echo()`, il bounding box del solido davvero prodotto, e il fatto che
cambiando un parametro il solido cambi di conseguenza.

:::note
Quest'ultimo controllo verifica che il modello **reagisca**, non di quanto.
Allungando la batteria di 12 mm il contenitore cresce di 10,2: con le quote
di partenza a comandare la lunghezza e' il vano elettronica (50,6 mm) e non
la batteria (48,8 mm). Pretendere la crescita esatta vorrebbe dire
riscrivere nel controllo la logica del modello, cioe' verificarlo con se
stesso.
:::

## Cosa resta fuori, deliberatamente

- **Tenuta stagna e resistenza al calore**: la batteria va tenuta lontana
  dalle superfici calde, non protetta dal contenitore. Sopra i ~45 °C una
  LiPo non va caricata.
- **Fissaggio definitivo alla stufa**: dipende dal coperchio della
  tramoggia, si decide dal vero. I vincoli — almeno 4–5 cm sopra il livello
  massimo del pellet, niente contatto con coclea e microinterruttore di
  sicurezza — sono parametri del modello, non geometria fissata.

## Stato della CI

Il job `contenitore` del workflow `hardware` ora e' attivo: genera gli STL,
controlla che non siano vuoti ed esegue `check_case.py`. Il render PNG di
questa pagina lo produce `tools/render.sh`, nel workflow `docs`.
