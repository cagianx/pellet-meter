---
title: "Pacchetto BTHome"
description: "Formato del pacchetto BLE advertising, BTHome v2 non cifrato."
---

# Pacchetto BTHome v2

AD flags `02 01 06` + AD Service Data con UUID **`0xFCD2`**. Gli oggetti
vanno in **ordine crescente di ID**: non e' un dettaglio estetico, e'
richiesto dal formato.

| Byte | Significato |
|---|---|
| `0x40` | Device info: BTHome v2, non cifrato (`0x44` = trigger-based) |
| `0x00` `<u8>` | Packet id — contatore in RTC memory, Home Assistant lo usa per scartare i duplicati |
| `0x01` `<u8>` | Batteria in % |
| `0x0C` `<u16 LE>` | Tensione in mV (fattore 0,001 → V) |
| `0x40` `<u16 LE>` | Distanza in mm |

Esempio di AD Service Data:

```
0E 16 D2 FC 40 00 <pid> 01 <bat> 0C <mV_lo> <mV_hi> 40 <mm_lo> <mm_hi>
```

Il primo byte `0x0E` e' la lunghezza: 14 byte seguono. Tornano —
`16 D2 FC 40 00 pid 01 bat 0C lo hi 40 lo hi` sono esattamente 14.

:::note
Il valore `0x40` compare due volte con significati diversi: come **device
info** in testa al payload, e come **ID dell'oggetto distanza** piu' avanti.
Non e' un errore.
:::

## Decisione aperta: `0x40` o `0x44`

`0x44` dichiara un dispositivo *trigger-based*, cioe' che dorme e trasmette
solo ogni tanto. Va verificato come Home Assistant gestisce la
**disponibilita'** del dispositivo nei due casi: con `0x40` potrebbe
segnalarlo come non disponibile tra un risveglio e l'altro.

Formato di riferimento: <https://bthome.io/format/>
