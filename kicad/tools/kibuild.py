"""Costruttore di fogli .kicad_sch (formato KiCad 10, version 20260306)."""
import kisch
from kisch import pin_at, pin_out, uid

GRID = 1.27   # la griglia di connessione di KiCad e' ancorata a zero:
              # le coordinate devono essere multipli di 1.27, altrimenti
              # l'ERC segnala "endpoint off grid"


def g(n):
    """n passi di griglia in millimetri."""
    return round(n * GRID, 4)


class Sheet:
    def __init__(self, project, title='', rev='', company='', date='', paper='A4'):
        self.project = project
        self.title, self.rev, self.company, self.date = title, rev, company, date
        self.paper = paper
        self.root = uid('root')
        self.used = {}
        self.items = []
        self.parts = []     # (ref, value, footprint) per la distinta

    # ---------- componenti ----------
    def symbol(self, lib, name, ref, value, x, y, rot=0, mirror=None,
               footprint=None, ref_off=(2.54, -1.27), val_off=(2.54, 1.27),
               hide_ref=False, hide_val=False, in_bom=True):
        self.used[(lib, name)] = True
        if in_bom:
            self.parts.append((ref, value, footprint or ''))
        body = ['\t(symbol', f'\t\t(lib_id "{lib}:{name}")', f'\t\t(at {x} {y} {rot})']
        if mirror:
            body.append(f'\t\t(mirror {mirror})')
        body += ['\t\t(unit 1)', '\t\t(exclude_from_sim no)',
                 f'\t\t(in_bom {"yes" if in_bom else "no"})',
                 '\t\t(on_board yes)', '\t\t(dnp no)',
                 f'\t\t(uuid "{uid("sym/" + ref)}")']

        def field(pname, pvalue, px, py, hide=False):
            out = [f'\t\t(property "{pname}" "{pvalue}"', f'\t\t\t(at {px} {py} 0)']
            if hide:
                out.append('\t\t\t(hide yes)')
            out += ['\t\t\t(effects', '\t\t\t\t(font', '\t\t\t\t\t(size 1.27 1.27)',
                    '\t\t\t\t)', '\t\t\t\t(justify left)', '\t\t\t)', '\t\t)']
            return out

        body += field('Reference', ref, x + ref_off[0], y + ref_off[1], hide_ref)
        body += field('Value', value, x + val_off[0], y + val_off[1], hide_val)
        body += field('Footprint', footprint or '', x, y, hide=True)
        body += field('Datasheet', '', x, y, hide=True)
        body += field('Description', '', x, y, hide=True)

        for num, _pn, _px, _py, _pr, _et in kisch.pins(lib, name):
            body += [f'\t\t(pin "{num}"', f'\t\t\t(uuid "{uid("pin/" + ref + "/" + num)}")', '\t\t)']

        body += ['\t\t(instances', f'\t\t\t(project "{self.project}"',
                 f'\t\t\t\t(path "/{self.root}"', f'\t\t\t\t\t(reference "{ref}")',
                 '\t\t\t\t\t(unit 1)', '\t\t\t\t)', '\t\t\t)', '\t\t)', '\t)']
        self.items.append('\n'.join(body))
        return self

    # ---------- connettivita' ----------
    def wire(self, p1, p2, tag=''):
        self.items.append(
            '\t(wire\n\t\t(pts\n'
            f'\t\t\t(xy {p1[0]} {p1[1]}) (xy {p2[0]} {p2[1]})\n\t\t)\n'
            '\t\t(stroke\n\t\t\t(width 0)\n\t\t\t(type default)\n\t\t)\n'
            f'\t\t(uuid "{uid("wire/" + str(p1) + str(p2) + tag)}")\n\t)')
        return self

    def label(self, text, p, rot=0, justify='left bottom'):
        self.items.append(
            f'\t(label "{text}"\n\t\t(at {p[0]} {p[1]} {rot})\n'
            '\t\t(effects\n\t\t\t(font\n\t\t\t\t(size 1.27 1.27)\n\t\t\t)\n'
            f'\t\t\t(justify {justify})\n\t\t)\n'
            f'\t\t(uuid "{uid("lbl/" + text + str(p))}")\n\t)')
        return self

    def net(self, lib, name, ref_pos, number, netname, steps=2):
        """Spezzone di filo uscente dal pin + etichetta di rete.

        Collegare per etichetta invece che per filo lungo tiene la geometria
        banale e rende le reti leggibili sia nel PDF che nell'ERC.
        """
        p = pin_at(lib, name, number, *ref_pos)
        dx, dy = pin_out(lib, name, number)
        q = (round(p[0] + dx * g(steps), 4), round(p[1] + dy * g(steps), 4))
        self.wire(p, q, netname)
        # orienta l'etichetta lungo il filo e la allinea verso l'esterno
        if dx < 0:
            self.label(netname, q, 180, 'right bottom')
        elif dx > 0:
            self.label(netname, q, 0, 'left bottom')
        elif dy < 0:
            self.label(netname, q, 90, 'left bottom')
        else:
            self.label(netname, q, 270, 'right bottom')
        return q

    def no_connect(self, lib, name, ref_pos, number):
        p = pin_at(lib, name, number, *ref_pos)
        self.items.append(
            f'\t(no_connect\n\t\t(at {p[0]} {p[1]})\n'
            f'\t\t(uuid "{uid("nc/" + str(p))}")\n\t)')
        return self

    def text(self, body, p, size=1.27, justify='left top'):
        # i ritorni a capo vanno scritti come escape \n dentro la stringa
        # quotata: un newline vero manda in errore il caricamento dello schema
        esc = (body.replace('\\', '\\\\').replace('"', '\\"')
                   .replace('\n', '\\n'))
        self.items.append(
            f'\t(text "{esc}"\n\t\t(exclude_from_sim no)\n'
            f'\t\t(at {p[0]} {p[1]} 0)\n'
            f'\t\t(effects\n\t\t\t(font\n\t\t\t\t(size {size} {size})\n\t\t\t)\n'
            f'\t\t\t(justify {justify})\n\t\t)\n'
            f'\t\t(uuid "{uid("txt/" + str(p) + body[:20])}")\n\t)')
        return self

    # ---------- output ----------
    def render(self):
        defs = '\n'.join('\t\t' + kisch.lib_symbol(lib, nm).replace('\n', '\n\t')
                         for (lib, nm) in self.used)
        tb = ['\t(title_block']
        for tag, val in (('title', self.title), ('date', self.date),
                         ('rev', self.rev), ('company', self.company)):
            if val:
                tb.append(f'\t\t({tag} "{val}")')
        tb.append('\t)')
        return ('(kicad_sch\n\t(version 20260306)\n\t(generator "eeschema")\n'
                '\t(generator_version "10.0")\n'
                f'\t(uuid "{self.root}")\n\t(paper "{self.paper}")\n'
                + '\n'.join(tb) + '\n'
                '\t(lib_symbols\n' + defs + '\n\t)\n'
                + '\n'.join(self.items) + '\n'
                '\t(sheet_instances\n\t\t(path "/"\n\t\t\t(page "1")\n\t\t)\n\t)\n'
                '\t(embedded_fonts no)\n)\n')

    def write(self, path):
        open(path, 'w').write(self.render())
        return path
