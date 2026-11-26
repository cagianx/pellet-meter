#!/usr/bin/env python3
"""Genera kicad/pellet-meter.kicad_sch.

Strumento di bootstrap: ha creato lo schema iniziale via script, in modo che
le reti fossero verificabili con l'ERC da riga di comando. Una volta che lo
schema viene modificato nella GUI di KiCad, il file .kicad_sch diventa la
fonte di verita' e questo script resta come documentazione di come e' nato.
Non rieseguirlo sopra modifiche fatte a mano senza prima guardare il diff.

Le reti sono collegate per etichetta e non per filo lungo: la geometria resta
banale, le reti sono leggibili nel PDF e l'ERC le verifica comunque.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
KICAD = os.path.dirname(HERE)
sys.path.insert(0, HERE)

import kisch                                      # noqa: E402
kisch.SYMLIBS['pellet-meter'] = os.path.join(KICAD, 'lib', 'pellet-meter.kicad_sym')

from kibuild import Sheet, g                      # noqa: E402

PROJECT = 'pellet-meter'
XIAO = ('pellet-meter', 'XIAO-ESP32-C6')
VL53 = ('pellet-meter', 'VL53L1X_Breakout')

# footprint pensati per il montaggio su millefori (componenti a foro passante)
FP_R = 'Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal'
FP_C_SMALL = 'Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P5.00mm'
FP_C_BULK = 'Capacitor_THT:CP_Radial_D5.0mm_P2.00mm'
FP_HDR6 = 'Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical'
FP_HDR2 = 'Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical'

s = Sheet(PROJECT, paper='A3',
          title='pellet-meter — sensore livello pellet BLE/BTHome',
          rev='A', company='', date='2026-11-26')

# ---------------------------------------------------------------- componenti
P_U1 = (g(110), g(70))      # XIAO ESP32C6
P_U2 = (g(190), g(58))      # breakout VL53L1X
P_BT1 = (g(50), g(70))      # LiPo
P_R1 = (g(70), g(55))       # partitore, lato alto
P_R2 = (g(70), g(68))       # partitore, lato basso
P_C1 = (g(80), g(68))       # filtro sul nodo ADC
P_C2 = (g(170), g(60))      # bulk sull'alimentazione del sensore
P_C3 = (g(178), g(60))      # disaccoppiamento sul sensore
P_F1 = (g(150), g(80))      # PWR_FLAG su GND
P_F2 = (g(162), g(44))      # PWR_FLAG su VSENS

s.symbol(*XIAO, 'U1', 'XIAO-ESP32-C6', *P_U1,
         footprint='pellet-meter:XIAO-ESP32-C6-DIP',
         ref_off=(-15.24, -24.13), val_off=(-15.24, 26.67))
s.symbol(*VL53, 'U2', 'VL53L1X', *P_U2, footprint=FP_HDR6,
         ref_off=(-7.62, -10.16), val_off=(-7.62, 12.7))
s.symbol('Device', 'Battery_Cell', 'BT1', 'LiPo 3.7V 1000mAh', *P_BT1, footprint=FP_HDR2)
s.symbol('Device', 'R', 'R1', '1M', *P_R1, footprint=FP_R)
s.symbol('Device', 'R', 'R2', '1M', *P_R2, footprint=FP_R)
s.symbol('Device', 'C', 'C1', '100nF', *P_C1, footprint=FP_C_SMALL)
s.symbol('Device', 'C', 'C2', '10uF', *P_C2, footprint=FP_C_BULK)
s.symbol('Device', 'C', 'C3', '100nF', *P_C3, footprint=FP_C_SMALL)
s.symbol('power', 'PWR_FLAG', '#FLG01', 'PWR_FLAG', *P_F1, hide_ref=True, in_bom=False)
s.symbol('power', 'PWR_FLAG', '#FLG02', 'PWR_FLAG', *P_F2, hide_ref=True, in_bom=False)

# ---------------------------------------------------------------------- reti
# batteria e misura della tensione
s.net(*XIAO, P_U1, 23, 'VBAT')          # pad VBAT dello XIAO
s.net('Device', 'Battery_Cell', P_BT1, 1, 'VBAT')
s.net('Device', 'Battery_Cell', P_BT1, 2, 'GND')
s.net('Device', 'R', P_R1, 1, 'VBAT')
s.net('Device', 'R', P_R1, 2, 'BAT_SENSE')
s.net('Device', 'R', P_R2, 1, 'BAT_SENSE')
s.net('Device', 'R', P_R2, 2, 'GND')
s.net('Device', 'C', P_C1, 1, 'BAT_SENSE')
s.net('Device', 'C', P_C1, 2, 'GND')
s.net(*XIAO, P_U1, 1, 'BAT_SENSE')      # D0 / GPIO0, ingresso ADC

# alimentazione commutata del sensore e I2C
s.net(*XIAO, P_U1, 3, 'VSENS')          # D2 / GPIO2 alimenta il sensore
s.net(*XIAO, P_U1, 4, 'XSHUT')          # D3 / GPIO21
s.net(*XIAO, P_U1, 5, 'SDA')            # D4 / GPIO22
s.net(*XIAO, P_U1, 6, 'SCL')            # D5 / GPIO23
s.net(*VL53, P_U2, 1, 'VSENS')
s.net(*VL53, P_U2, 2, 'GND')
s.net(*VL53, P_U2, 3, 'SDA')
s.net(*VL53, P_U2, 4, 'SCL')
s.net(*VL53, P_U2, 5, 'XSHUT')
s.net('Device', 'C', P_C2, 1, 'VSENS')
s.net('Device', 'C', P_C2, 2, 'GND')
s.net('Device', 'C', P_C3, 1, 'VSENS')
s.net('Device', 'C', P_C3, 2, 'GND')

# masse dello XIAO
s.net(*XIAO, P_U1, 13, 'GND')
s.net(*XIAO, P_U1, 18, 'GND')
s.net(*XIAO, P_U1, 24, 'GND')

# i PWR_FLAG dicono all'ERC che queste reti sono alimentate
s.net('power', 'PWR_FLAG', P_F1, 1, 'GND')
s.net('power', 'PWR_FLAG', P_F2, 1, 'VSENS')

# ------------------------------------------------------- pin non utilizzati
# marcarli esplicitamente: l'ERC altrimenti li segnala uno per uno
for n in (2, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 19, 20, 21, 22):
    s.no_connect(*XIAO, P_U1, n)
s.no_connect(*VL53, P_U2, 6)            # GPIO1 (interrupt), non usato

# ------------------------------------------------------------------- note
s.text('ALIMENTAZIONE DEL SENSORE — il VL53L1X e\' alimentato direttamente\n'
       'dal GPIO D2. Il GPIO dell\'ESP32-C6 regge ~20 mA in sicurezza e il\n'
       'sensore ne assorbe circa altrettanti in misura, con picchi quando\n'
       'spara il VCSEL: C2 e C3 servono a sostenere quei picchi.\n'
       'SE le letture risultano instabili o il sensore non si avvia,\n'
       'sostituire con un interruttore high-side: P-MOSFET DMG2301L\n'
       '(SOT-23, serve un adattatore su millefori), source a 3V3_OUT,\n'
       'drain a VSENS, gate a D2 con 100k di pull-up verso 3V3_OUT.\n'
       'Attenzione: con il MOSFET la logica si inverte, D2 basso = acceso.',
       (g(20), g(100)), size=1.27)

s.text('PARTITORE BATTERIA — 2x1M danno ~2.1 uA a 4.2 V, trascurabili\n'
       'rispetto al consumo in deep sleep dello XIAO. Con 100k sarebbero\n'
       '~21 uA e raddoppierebbero il consumo a riposo.\n'
       'L\'impedenza e\' alta (500k): C1 stabilizza la lettura dell\'ADC.\n'
       'A 4.2 V il nodo sta a 2.1 V, dentro il range dell\'ADC a 12 dB.',
       (g(20), g(118)), size=1.27)

s.text('PRIMA DEL DEEP SLEEP — mettere SDA, SCL e XSHUT in uno stato che non\n'
       'faccia passare corrente nel sensore spento attraverso i pull-up I2C\n'
       'del breakout, che sono alimentati dalla rete VSENS.\n'
       'ANTENNA — lo XIAO ESP32C6 ha uno switch RF comandato da GPIO interni\n'
       '(non sui 14 pin del connettore): va impostato a ogni risveglio prima\n'
       'di inizializzare il BLE, altrimenti l\'advertising esce attenuato.',
       (g(20), g(134)), size=1.27)

s.text('ORDINE DEI PIN DEL BREAKOUT — varia tra produttori.\n'
       'Verificare la serigrafia della scheda prima di saldare.',
       (g(150), g(100)), size=1.27)

# ----------------------------------------------------------------- scrittura
out = os.path.join(KICAD, f'{PROJECT}.kicad_sch')
s.write(out)
print(f'scritto {out}')
print(f'componenti in distinta: {len(s.parts)}')
for ref, value, fp in s.parts:
    print(f'  {ref:<6} {value:<22} {fp}')
