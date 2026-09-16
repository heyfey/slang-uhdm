#!/usr/bin/env python3
"""r11u50 grid reader — the ENCODING of the substituted leaf under a packed
range bound, read in BOTH views.

A grid cell is one `logic [<P>-1:0] cNN;` declaration.  In the DEF listing
(`uhdmallModules`) the bound stays an `operation` whose FIRST operand is the
substituted leaf — the ibex_icache head's exact shape; in the ELABORATED
listing the whole bound folds to one constant.  Both are printed.

usage: gread50.py <lhs.raw> <rhs.raw> <names.txt>
       names.txt: one `<declLine> <cellName>` pair per line.
"""
import re, sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from cenc50 import objects, tsname

LINE = re.compile(r'line:(\d+):')


def enc(c):
    if c is None:
        return None
    if c['_kind'] != 'constant':
        return (c['_kind'],)
    return (c.get('_valtag', '-'), (c.get('_val', '-') or '-').strip(),
            c.get('vpiSize', '-').strip(), c.get('vpiConstType', '-').strip(),
            tsname(c))


def cells(path, names):
    out = {}
    for d in objects(path):
        if d['_kind'] not in ('logic_typespec', 'int_typespec', 'bit_typespec',
                              'packed_array_typespec', 'array_typespec'):
            continue
        m = LINE.search(d.get('_hdr', '') or '')
        ln = d.get('_line')
        if ln is None:
            continue
        nm = names.get(ln)
        if not nm:
            continue
        rng = d.get('child:vpiRange')
        if rng is None:
            continue
        left = rng.get('child:vpiLeftExpr') or rng.get('child:vpiLeftRange')
        if left is None:
            continue
        view = 'ELAB' if d.get('child:vpiParent') is not None else 'DEF'
        if left['_kind'] == 'operation':
            leaf = left.get('child:vpiOperand')
            row = ('op%s' % left.get('vpiOpType', '?').strip(), enc(leaf))
        else:
            row = ('fold', enc(left))
        out.setdefault((nm, view), row)
    return out


def main():
    names = {}
    for ln in open(sys.argv[3]):
        ln = ln.split('#')[0].split()
        if len(ln) == 2:
            names[ln[0]] = ln[1]
    a, b = cells(sys.argv[1], names), cells(sys.argv[2], names)
    same = diff = 0
    for k in sorted(set(a) | set(b)):
        ra, rb = a.get(k), b.get(k)
        if ra == rb:
            same += 1
            print('SAME %-6s %-5s %s' % (k[0], k[1], ra))
        else:
            diff += 1
            print('DIFF %-6s %-5s G=%s' % (k[0], k[1], ra))
            print('                   O=%s' % (rb,))
    print('CELLS %d SAME %d DIFF %d' % (len(set(a) | set(b)), same, diff))


main()
