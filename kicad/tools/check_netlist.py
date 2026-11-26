#!/usr/bin/env python3
"""Verifica che le reti dello schema siano quelle attese.

L'ERC pulito non basta: un errore di battitura in un'etichetta produce una
rete isolata senza far scattare nessun errore. Questo script confronta la
netlist esportata con la connettivita' attesa, nodo per nodo.

Uso:
    kicad-cli sch export netlist --format kicadsexpr -o out/pm.net pellet-meter.kicad_sch
    python3 tools/check_netlist.py out/pm.net

Esce con codice 1 se qualcosa non corrisponde.
"""
import re
import sys

# rete -> insieme di "REF.pin" attesi
#
# L'alimentazione del sensore ha due configurazioni sullo stesso rame, scelte
# con il ponticello JP1 (vedi docs/hardware/pcb/). Da qui si vedono entrambe:
# D2 comanda SENS_CTRL, che arriva al gate di Q1 e al pad 1 di JP1; VSENS,
# che alimenta il sensore, arriva al pad 2; il drain di Q1 al pad 3. Quale
# delle due e' attiva lo decide la goccia di stagno, non la netlist.
ATTESE = {
    'GND': {'BT1.2', 'C1.2', 'C2.2', 'C3.2', 'R2.2',
            'U1.13', 'U1.18', 'U1.24', 'U2.2'},
    'BAT_SENSE': {'C1.1', 'R1.2', 'R2.1', 'U1.1'},
    'VSENS': {'C2.1', 'C3.1', 'JP1.2', 'U2.1'},
    'VBAT': {'BT1.1', 'R1.1', 'U1.23'},
    'SDA': {'U1.5', 'U2.3'},
    'SCL': {'U1.6', 'U2.4'},
    'XSHUT': {'U1.4', 'U2.5'},
    'SENS_CTRL': {'JP1.1', 'Q1.1', 'R3.2', 'U1.3'},
    'SW_OUT': {'JP1.3', 'Q1.3'},
    '3V3_OUT': {'Q1.2', 'R3.1', 'U1.12'},
}

# pin lasciati deliberatamente scollegati: devono restare reti a nodo singolo
SCOLLEGATI_ATTESI = {
    'U1.2', 'U1.7', 'U1.8', 'U1.9', 'U1.10', 'U1.11', 'U1.14',
    'U1.15', 'U1.16', 'U1.17', 'U1.19', 'U1.20', 'U1.21', 'U1.22', 'U2.6',
}


def leggi(path):
    testo = open(path).read()
    sezione = testo[testo.index('(nets'):]
    reti = {}
    for blocco in re.split(r'\n\t\t\(net\n', sezione)[1:]:
        nome = re.search(r'\(name "([^"]*)"\)', blocco).group(1).lstrip('/')
        nodi = {f'{r}.{p}' for r, p in
                re.findall(r'\(ref "([^"]+)"\)\s*\n\s*\(pin "([^"]+)"\)', blocco)}
        reti[nome] = nodi
    return reti


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    reti = leggi(sys.argv[1])
    errori = []

    for nome, attesi in ATTESE.items():
        trovati = reti.get(nome)
        if trovati is None:
            errori.append(f'rete {nome}: ASSENTE dalla netlist')
            continue
        if trovati != attesi:
            mancanti = attesi - trovati
            extra = trovati - attesi
            dett = []
            if mancanti:
                dett.append(f'mancano {sorted(mancanti)}')
            if extra:
                dett.append(f'in piu\' {sorted(extra)}')
            errori.append(f'rete {nome}: ' + ', '.join(dett))
        else:
            print(f'  ok  {nome:<12} {len(trovati)} nodi')

    # i pin scollegati devono essere esattamente quelli previsti
    scollegati = set()
    for nome, nodi in reti.items():
        if nome.startswith('unconnected-') and len(nodi) == 1:
            scollegati |= nodi
    if scollegati != SCOLLEGATI_ATTESI:
        inattesi = scollegati - SCOLLEGATI_ATTESI
        ricollegati = SCOLLEGATI_ATTESI - scollegati
        if inattesi:
            errori.append(f'pin scollegati non previsti: {sorted(inattesi)}')
        if ricollegati:
            errori.append(f'pin previsti scollegati ma ora collegati: {sorted(ricollegati)}')
    else:
        print(f'  ok  {len(scollegati)} pin scollegati, tutti previsti')

    if errori:
        print('\nNETLIST NON CONFORME:')
        for e in errori:
            print(f'  - {e}')
        return 1
    print(f'\nnetlist conforme: {len(ATTESE)} reti verificate')
    return 0


if __name__ == '__main__':
    sys.exit(main())
