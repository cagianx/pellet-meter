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
| `0x44` | Device info: BTHome v2, non cifrato, **trigger-based** (vedi sotto) |
| `0x00` `<u8>` | Packet id — contatore in RTC memory, Home Assistant lo usa per scartare i duplicati |
| `0x01` `<u8>` | Batteria in % |
| `0x0C` `<u16 LE>` | Tensione in mV (fattore 0,001 → V) |
| `0x40` `<u16 LE>` | Distanza in mm |

Esempio di AD Service Data:

```
0E 16 D2 FC 44 00 <pid> 01 <bat> 0C <mV_lo> <mV_hi> 40 <mm_lo> <mm_hi>
```

Il primo byte `0x0E` e' la lunghezza: 14 byte seguono. Tornano —
`16 D2 FC 44 00 pid 01 bat 0C lo hi 40 lo hi` sono esattamente 14.

## Il byte di device info, bit per bit

| Bit | Significato | Valore nostro |
|---|---|---|
| 0 | Cifratura | `0` — non cifrato |
| 1 | Riservato | `0` |
| 2 | **Trigger-based**: `1` = intervalli irregolari | `1` |
| 3–4 | Riservati | `0` |
| 5–7 | Versione BTHome | `010` = v2 |

`010` << 5 = `0x40`, piu' il bit 2 = **`0x44`**.

:::note
L'ID dell'oggetto distanza e' anch'esso `0x40`, quindi nelle tabelle il
valore `0x40` compare in due ruoli diversi. Con `0x44` in testa al payload
l'ambiguita' si nota meno, ma resta utile sapere che esiste.
:::

## Decisione: `0x44`, trigger-based

La scelta e' `0x44`, e la ragione sta in tre righe di Home Assistant
(`homeassistant/components/bthome/sensor.py`):

```python
@property
def available(self) -> bool:
    """Return True if entity is available."""
    return self.processor.coordinator.sleepy_device or super().available
```

`sleepy_device` e' esattamente il bit 2 del device info, letto da
`bthome-ble` (`parser.py`, `_is_sleepy_device`) e **salvato nella config
entry**, quindi sopravvive al riavvio di Home Assistant. Con `0x44` le
entita' risultano **sempre disponibili**; con `0x40` la disponibilita'
dipende dal tracciamento di `habluetooth`, che confronta il tempo dall'ultimo
advertisement con l'intervallo di advertising **imparato** dal dispositivo:

- se l'intervallo e' noto, la soglia e' quell'intervallo piu' un margine:
  **un solo pacchetto perso basta a far sparire il dispositivo**
- se non e' noto, vale il fallback `FALLBACK_MAXIMUM_STALE_ADVERTISEMENT_SECONDS`,
  **900 s**

:::warning
Il prezzo di `0x44` e' che il dispositivo **non va mai in `unavailable`**:
batteria morta, sensore guasto e tutto funzionante si assomigliano. Il
controllo di vitalita' va fatto in Home Assistant sull'**eta' del dato**
(`last_changed` / `last_updated` dell'entita'), non sulla disponibilita'.
Il change `calibrazione-home-assistant` se ne fa carico.
:::

## Il packet id serve, ma non per quello che si crede

`bthome-ble` scarta un advertisement duplicato **solo se sono passati meno di
4 secondi** dal precedente (`_skip_old_or_duplicated_advertisement`). Oltre i
4 secondi il pacchetto viene accettato anche con packet id identico.

Conseguenze pratiche:

- il packet id **non** serve a deduplicare tra un risveglio e l'altro: a 10
  minuti di distanza nessun filtro scatta
- serve **dentro la raffica**: durante l'advertising da ~1 s lo stesso
  pacchetto esce molte volte, e il packet id evita che Home Assistant lo
  conti come letture ripetute
- va **incrementato di uno per ciclo**, e non di piu': quando il filtro e'
  attivo accetta il pacchetto solo se la distanza dal precedente e' minore di
  64 (con rollover a 255 → 0), altrimenti lo legge come un pacchetto vecchio
  arrivato in ritardo

Formato di riferimento: <https://bthome.io/format/>
