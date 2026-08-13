#!/usr/bin/env python3
"""r10uvm68 — the CELL GRID: for every arm cell NAME, does the variable object
carry `vpiSigned`, on GOLDEN (LHS) and on OURS (RHS)?

  usage: ct68cells.py <g.dump> <o.dump>

CONVENTION, enforced by the header this prints: LHS is ALWAYS golden (Surelog),
RHS is ALWAYS ours.

An object printed CHILDLESSLY is a BACK-REFERENCE, not an object, and is never
counted: a back-reference prints no fields at all, so counting it would report
`vpiSigned absent` for every object in the database.

Cells are keyed on the variable's LEAF NAME (`vpiName`), which the arms make
unique.  A side that emits NO object for a cell prints `UNMEASURED` rather than
`-`, because "golden omits the field" and "we omit the object" are different
findings and conflating them is how an over-fire reads as agreement.
"""
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from dumptree import parse, is_backref   # noqa: E402

KEYMODE = __import__('os').environ.get('KEY', 'name')

VARKINDS = ('int_var', 'integer_var', 'byte_var', 'short_int_var',
            'long_int_var', 'time_var', 'bit_var', 'logic_var', 'ref_var',
            'enum_var', 'array_var', 'packed_array_var', 'real_var',
            'short_real_var', 'string_var', 'class_var', 'struct_var')


def side(path):
    _r, nodes = parse(path)
    out = {}
    for n in nodes:
        if n.kind not in VARKINDS or is_backref(n):
            continue
        nm = n.fields.get('vpiName') or (
            n.name.replace('::', '.').rsplit('.', 1)[-1] if n.name else '')
        if not nm:
            continue
        # KEY=span keys cells on the SOURCE SPAN instead of the leaf name.  Two
        # arms need it: where a NAMING residue makes the two sides disagree on
        # vpiName for the SAME object (a DPI-import return var is `q_t` in
        # golden and `dpi_ret` here), a name key silently drops the cell into
        # UNMEASURED on both sides and the disagreement never appears.  The name
        # is then carried as a COLUMN so the residue stays visible.
        if KEYMODE == 'span':
            nm = '%s@%s' % (n.kind, n.span)
        par = ''
        ts = ''
        for f, c in n.children:
            if f == 'vpiParent' and not par:
                par = c.kind
            if f == 'vpiTypespec':
                if c.kind == 'ref_typespec':
                    for f2, c2 in c.children:
                        if f2 == 'vpiActual':
                            ts = ('NAMED:' if c2.name else 'ANON:') + c2.kind
                else:
                    ts = ('NAMED:' if c.name else 'ANON:') + c.kind
        e = out.setdefault(nm, {'kind': n.kind, 'signed': '-', 'par': par,
                                'ts': ts or 'NOTS', 'n': 0,
                                'nm': n.fields.get('vpiName', '')})
        e['n'] += 1
        if 'vpiSigned' in n.fields:
            e['signed'] = n.fields['vpiSigned']
        if not e['par']:
            e['par'] = par
        if e['ts'] == 'NOTS' and ts:
            e['ts'] = ts
    return out


def main():
    g = side(sys.argv[1])
    o = side(sys.argv[2])
    print('LHS = GOLDEN (%s)      RHS = OURS (%s)   KEY=%s'
          % (sys.argv[1], sys.argv[2], KEYMODE))
    names = sorted(set(g) | set(o))
    hdr = ('%-28s | %-16s %-8s %-22s | %-16s %-8s %-22s | %s'
           % ('cell', 'G kind', 'G signed', 'G typespec',
              'O kind', 'O signed', 'O typespec', 'verdict'))
    print(hdr)
    print('-' * len(hdr))
    tally = {'EQ': 0, 'DIFFER': 0, 'DIFFERKIND': 0, 'UNMEASURED': 0}
    for nm in names:
        a = g.get(nm)
        b = o.get(nm)
        if a is None or b is None:
            v = 'UNMEASURED'
        elif a['kind'] != b['kind']:
            v = 'DIFFERKIND'
        elif a['signed'] != b['signed']:
            v = 'DIFFER'
        else:
            v = 'EQ'
        tally[v] += 1
        f = lambda e: (e['kind'], e['signed'], e['ts']) if e else ('-', '-', '-')
        print('%-28s | %-16s %-8s %-22s | %-16s %-8s %-22s | %s'
              % ((nm,) + f(a) + f(b) + (v,)))
    print('---- cells=%d  EQ=%d  DIFFER=%d  DIFFERKIND=%d  UNMEASURED=%d'
          % (len(names), tally['EQ'], tally['DIFFER'], tally['DIFFERKIND'],
             tally['UNMEASURED']))


if __name__ == '__main__':
    main()
