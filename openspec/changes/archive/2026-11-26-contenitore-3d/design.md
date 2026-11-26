# Design

## Context

Vedi proposal.md. Le quote dei componenti non sono ancora state misurate
sull'hardware reale: XIAO 21x17,5 mm e LiPo 603048 (6x30x48 mm) vengono dai
datasheet, il breakout VL53L1X varia tra produttori.

## Goals / Non-Goals

**Goals:**
- Modello parametrico, rigenerabile quando arrivano le misure reali.
- Stampabile senza supporti.

**Non-Goals:**
- Tenuta stagna o resistenza alle alte temperature: la batteria va comunque
  tenuta lontana dalle superfici calde, non protetta dal contenitore.
- Fissaggio definitivo alla stufa: dipende dal coperchio, si decide dal vero.

## Decisions

- **OpenSCAD invece di FreeCAD**: il modello e' testuale, quindi versionabile,
  diffabile e rigenerabile dalla CI. Blender e' lo strumento sbagliato per
  quote meccaniche.
- **Tolleranze come parametro, non costanti sparse**: il ritiro varia per
  stampante e materiale; deve bastare un numero da cambiare.
- **Due pezzi (scatola + coperchio)** invece di un pezzo con cerniera stampata:
  piu' semplice da stampare e da iterare.

## Risks / Trade-offs

- Le quote sono da datasheet, non misurate: il primo esemplare stampato serve
  a verificare gli accoppiamenti, non a essere installato.
- L'ordine dei pin del breakout varia tra produttori e puo' cambiare
  l'ingombro: il supporto del sensore va tenuto generoso finche' non si ha la
  scheda in mano.
