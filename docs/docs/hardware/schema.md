---
title: "Schema elettrico"
description: "Il progetto KiCad, come e' fatto e come si verifica."
---

# Schema elettrico

Progetto **KiCad 10** in `kicad/`. Il file `pellet-meter.kicad_sch` e' la
fonte di verita'.

<a href="/assets/render/schema.svg">
  <img src="/assets/render/schema.svg" alt="Schema elettrico del pellet-meter"
       style="width:100%;background:#fff;padding:1rem;border-radius:6px;box-sizing:border-box">
</a>

[Apri l'SVG a tutta pagina](/assets/render/schema.svg) ·
[Scarica il PDF da stampare](/assets/render/schema.pdf)

:::note
Il fondo bianco e' messo apposta: KiCad esporta tratto nero su sfondo
trasparente, e in tema scuro lo schema sparirebbe. Da telefono conviene
aprire l'SVG a tutta pagina e ingrandire: un A3 dentro la larghezza di uno
schermo da telefono non si legge, e nessun accorgimento tipografico lo
cambia.
:::

L'immagine e' **generata**, non versionata: la produce `tools/render.sh`,
che gira in locale e nel workflow `docs`. Lo stesso script esporta anche il
PDF e la distinta componenti resta un artefatto del workflow `hardware`
([ultimi run](https://github.com/cagianx/pellet-meter/actions)).

## Componenti

| Rif | Valore | Note |
|---|---|---|
| U1 | XIAO-ESP32-C6 | Footprint DIP: header su millefori, header femmina sul PCB |
| U2 | VL53L1X | Breakout su header a 6 pin |
| BT1 | LiPo 3,7 V 1000 mAh | |
| R1, R2 | 1 MΩ | Partitore della batteria |
| C1 | 100 nF | Stabilizza il nodo ADC |
| C2 | 10 µF | Bulk sull'alimentazione del sensore |
| C3 | 100 nF | Disaccoppiamento del sensore |
| Q1 | DMG2301L | Interruttore high-side del sensore. **DNP**: si monta solo nella configurazione a MOSFET |
| R3 | 100 kΩ | Pull-up di gate di Q1. **DNP**, come Q1 |
| JP1 | Ponticello a 3 piazzole | Sceglie l'alimentazione del sensore: 1-2 diretta, 2-3 a MOSFET |

Q1, R3 e JP1 esistono perche' il PCB non deve congelare l'unica scelta
hardware ancora aperta: vedi [Circuito stampato](/hardware/pcb/).

## Librerie di progetto

Il simbolo e il footprint dello XIAO ESP32C6 **non sono nelle librerie
standard di KiCad**: vengono dalla
[libreria OPL di Seeed](https://github.com/Seeed-Studio/OPL_Kicad_Library)
e sono copiati in `kicad/lib/`. Viene usato il footprint **DIP** (fori
passanti), non quello SMD castellato: su millefori perche' non c'e'
alternativa, sul PCB perche' il modulo innestato si recupera. Il footprint
porta dieci piazzole in piu' rispetto all'originale, per i pin che lo XIAO
espone sul proprio fondo.

Il simbolo `DMG2301L` e' una copia rinominata di `Transistor_FET:TP0610T`:
quello di sistema e' derivato con `extends`, e un simbolo autonomo evita di
dover gestire l'ereditarieta' dentro lo schema.

Il simbolo del breakout VL53L1X e' scritto a mano: nelle librerie standard
c'e' solo il chip nudo (`VL53L1CXV0FY1`), che non corrisponde a una scheda
breakout con header.

## Lo schema e' corretto ma graficamente sbilanciato

E' stato generato via script per poter verificare le reti da riga di comando,
e la disposizione non e' stata curata. Elettricamente e' verificato;
graficamente va sistemato a mano nella GUI, ed e' il change
`schema-leggibile`.

Il render ha reso misurabili i difetti, che a parole erano solo "e' da
sistemare":

| Difetto | Dove | Nota |
|---|---|---|
| Etichette `BAT_SENSE` sovrapposte | sul partitore, tra R1 e R2 | due etichette della stessa rete finiscono una sopra l'altra: illeggibili entrambe |
| `GND` e `100nF` collisi | su C3, rete VSENS | il valore del condensatore si sovrappone all'etichetta di massa |
| Disegno in un angolo | tutto il foglio | il contenuto occupa **234 × 129 mm**, il 24% di un A3 |
| Blocco di Q1/R3/JP1 stretto | in basso a destra | le etichette `SENS_CTRL`, `SW_OUT` e `3V3_OUT` si accavallano fra loro e con la nota sul breakout |

Quei 234 × 129 mm starebbero in un **A4 orizzontale** (297 × 210), e ridurre
il formato e' gia' previsto. Ma l'angolo in basso a destra del disegno
arriva a (260, 182) mm, dove sull'A4 cade il **cartiglio**: ridurre il foglio
senza prima spostare i blocchi farebbe finire il disegno sopra il riquadro
delle informazioni. Prima la disposizione, poi il formato.

## Come si verifica

Vedi [Come si verifica](/know-how/verifica/): l'ERC pulito **non basta**.
