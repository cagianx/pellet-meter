"""Lettura delle librerie di simboli KiCad, per generare schemi via script.

Usato da gen_schematic.py. Legge i .kicad_sym (formato KiCad 10) ed estrae
blocchi di simbolo e coordinate dei pin.
"""
import re
import uuid

SYMLIBS = {
    'Device':         '/usr/share/kicad/symbols/Device.kicad_sym',
    'power':          '/usr/share/kicad/symbols/power.kicad_sym',
    'Transistor_FET': '/usr/share/kicad/symbols/Transistor_FET.kicad_sym',
    'pellet-meter':   None,   # impostato da gen_schematic.py (libreria di progetto)
}

_cache = {}


def _src(lib):
    if lib not in _cache:
        path = SYMLIBS[lib]
        if path is None:
            raise RuntimeError(f"percorso non impostato per la libreria '{lib}'")
        _cache[lib] = open(path).read()
    return _cache[lib]


def extract(lib, name):
    """Blocco (symbol "name" ...) completo, sotto-unita' incluse."""
    src = _src(lib)
    i = src.index(f'(symbol "{name}"')
    d = 0
    for j in range(i, len(src)):
        if src[j] == '(':
            d += 1
        elif src[j] == ')':
            d -= 1
            if d == 0:
                return src[i:j + 1]
    raise ValueError(f'blocco non chiuso: {lib}:{name}')


def lib_symbol(lib, name):
    """Il simbolo come va dentro (lib_symbols) dello schema.

    Solo il simbolo padre prende il prefisso "Lib:Nome". Le sotto-unita'
    ("Nome_0_1", "Nome_1_1") vanno lasciate col nome originale: se le si
    rinomina, KiCad rifiuta di caricare lo schema senza dire perche'.
    """
    return extract(lib, name).replace(f'(symbol "{name}"', f'(symbol "{lib}:{name}"', 1)


def pins(lib, name, _depth=0):
    """[(num, nome, x, y, rot, tipo)] con coordinate nel sistema della libreria.

    Segue (extends "Padre"): i simboli derivati (es. DMG2301L -> TP0610T)
    non ripetono i pin, li eredita dal genitore. Senza questo, un simbolo
    derivato restituirebbe zero pin e lo schema uscirebbe senza quei
    collegamenti, in silenzio.
    """
    block = extract(lib, name)
    out = []
    for m in re.finditer(
            r'\(pin\s+(\S+)\s+(\S+)\s*\(at ([-\d.]+) ([-\d.]+) (\d+)\)'
            r'.*?\(name "([^"]*)".*?\(number "([^"]*)"', block, re.S):
        etype, _shape, x, y, rot, pname, num = m.groups()
        out.append((num, pname, float(x), float(y), int(rot), etype))

    if not out:
        parent = re.findall(r'\(extends "([^"]+)"', block)
        if parent and _depth < 5:
            return pins(lib, parent[0], _depth + 1)
    return out


def pin_at(lib, name, number, inst_x, inst_y, inst_rot=0, mirror=None):
    """Coordinata nello SCHEMA del pin `number` di un'istanza in (inst_x, inst_y).

    Nei file .kicad_sch l'asse Y e' invertito rispetto alla libreria dei simboli.
    """
    import math
    for num, _pn, px, py, _pr, _et in pins(lib, name):
        if num == str(number):
            break
    else:
        raise ValueError(f'pin {number} non trovato in {lib}:{name}')

    if mirror == 'x':
        py = -py
    elif mirror == 'y':
        px = -px

    a = math.radians(inst_rot)
    rx = px * math.cos(a) - py * math.sin(a)
    ry = px * math.sin(a) + py * math.cos(a)
    return (round(inst_x + rx, 4), round(inst_y - ry, 4))


# direzione "verso l'esterno" del pin (lontano dal corpo), in coordinate schema
_OUT = {0: (-1.0, 0.0), 90: (0.0, 1.0), 180: (1.0, 0.0), 270: (0.0, -1.0)}


def pin_out(lib, name, number):
    """Versore uscente dal pin, nel sistema dello schema."""
    for num, _pn, _px, _py, prot, _et in pins(lib, name):
        if num == str(number):
            return _OUT[prot % 360]
    raise ValueError(f'pin {number} non trovato in {lib}:{name}')


def uid(seed):
    """UUID deterministico: rigenerare lo schema non cambia tutti gli id."""
    return str(uuid.uuid5(uuid.NAMESPACE_URL, 'pellet-meter/' + seed))
