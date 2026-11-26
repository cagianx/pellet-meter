---
title: "Contenitore 3D"
description: "Involucro stampabile: requisiti noti, progetto ancora da fare."
---

# Contenitore 3D

:::warning
**Non ancora progettato.** Qui ci sono i requisiti gia' fissati e le ragioni
per cui non e' stato ancora disegnato. Il lavoro e' tracciato nel change
OpenSpec `contenitore-3d`.
:::

## Perche' non e' ancora stato fatto

Le quote dei componenti non sono state misurate sull'hardware reale, e
soprattutto **non e' stata misurata la tramoggia**: distanza dal coperchio al
pellet a serbatoio pieno e vuoto, e forma del fondo. Disegnare adesso
significherebbe fissare numeri presi dai datasheet e rifare il lavoro dopo.

## Requisiti gia' fissati

- Elettronica e batteria **fuori** dal serbatoio; verso l'interno si affaccia
  solo la finestra ottica del sensore.
- Il cono di misura del sensore resta libero.
- La USB-C e' raggiungibile **senza aprire** il contenitore.
- Non tocca coclea ne' microinterruttore di sicurezza del coperchio.
- La batteria sta lontana dalle superfici calde: sopra i ~45 °C la LiPo non
  va caricata.

## Scelte tecniche gia' prese

- **OpenSCAD**, non FreeCAD e non Blender: il modello e' testuale, quindi
  versionabile, diffabile e rigenerabile dalla CI. Blender e' lo strumento
  sbagliato per quote meccaniche.
- **Modello parametrico**: quote dei componenti, spessore delle pareti e
  tolleranze come parametri in testa al file, non costanti sparse nella
  geometria. Il ritiro varia per stampante e materiale.
- **Due pezzi** (scatola + coperchio), piu' semplici da stampare e iterare di
  un pezzo unico con cerniera stampata.

## Stato della CI

Il job `contenitore` del workflow `hardware` esiste gia' e **si salta da
solo** finche' non compaiono file `.scad` in `enclosure/`. Quando ci saranno,
genera gli STL e li pubblica come artefatto.
