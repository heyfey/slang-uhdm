#!/usr/bin/env python3
"""r11u97 VIEW-KEYED boundary scorer — r11v96's `loc96v.py` with the DECOMPILE
field added and, more important, THE VIEW IN THE KEY.

`loc96v.py` keys a constant on its SOURCE LOCATION alone and compares the
values at that key as a sorted multiset.  A parameter written once is emitted
three times — once in the module DEFINITION (`uhdmallModules`) and once per
ELABORATED INSTANCE (`uhdmtopModules`) — and all three carry the SAME source
location, so a location-only key folds three different cells into one bag.
That bag hides a pristine-right -> patched-wrong cell whenever another cell at
the same location moves the other way: measured here, where golden decompiles
a one-bit `BIN:` as the bare `1` in the DEFINITION and as `<width>'b1` in every
instance, and a location-keyed score read `AWAY=0` over five real AWAY cells
(`z6_pahome97`, `r11v38repro/arms/v2_paenc.sv`, `r11u38repro/grid/
g2_paenc38.sv`).

The key here is (section, enclosing instance or package, line, col), so the
definition and each instance are scored apart.  Keys whose multiplicity still
differs between the three dumps are SKIPped rather than guessed at.

usage: loc97v.py <golden.dump> <before.dump> <after.dump>
"""
import collections
import re
import sys

# r11v97: the value is TWO fields — the PREFIX the laws write and the
# DIGITS that sit on the fenced size/fold residues.  The committed
# evidence/GRID97.score and evidence/BOUNDARY97.classes are the 5-field
# reading; the 4-field one the patch shipped cannot regenerate them.
FIELDS = ('vp', 'vd', 'ct', 'sz', 'd')


def read(p):
    res = collections.defaultdict(list)
    L = open(p, errors='replace').read().split('\n')
    sec, obj = '?', '?'
    for i, l in enumerate(L):
        m = re.match(r'\|(uhdm\w+):', l)
        if m:
            sec = m.group(1)
        # ONLY a section member, at column zero — a nested `\\_module_inst`
        # under a `vpiParent` is a back-reference, not a new view.
        m2 = re.match(r'\\_(module_inst|package|interface_inst|class_defn'
                      r'|program|udp_defn): \(?([^)\n,]*)', l)
        if m2:
            obj = m2.group(2)
        m3 = re.match(r'\s*\\_constant: .*line:(\d+):(\d+), '
                      r'endln:(\d+):(\d+)', l)
        if not m3:
            continue
        blk = '\n'.join(L[i + 1:i + 9])
        v = re.search(r'\|((?:INT|UINT|HEX|BIN|DEC|OCT|REAL|STRING):\S*)', blk)
        c = re.search(r'\|vpiConstType:(\d+)', blk)
        s = re.search(r'\|vpiSize:(-?\d+)', blk)
        d = re.search(r'\|vpiDecompile:(\S*)', blk)
        # the START location only: our `param_assign` constants carry a
        # different END COLUMN from golden's (`20:38..20:47` against
        # `20:38..20:43`), so an end-keyed reader never compares them at all
        # and reports AWAY=0 over cells it never looked at.
        vv97 = v.group(1) if v else '?'
        vp97, _, vd97 = vv97.partition(':')
        res[(sec, obj) + m3.groups()[:2]].append(
            (vp97, vd97, c.group(1) if c else '?',
             s.group(1) if s else '?', d.group(1) if d else '?'))
    return {k: sorted(v) for k, v in res.items()}


def main():
    g, a, b = (read(x) for x in sys.argv[1:4])
    tot = dict(TO=0, AWAY=0, STILL=0, EQ=0, MWRONG=0, SKIP=0)
    ex = []
    for k in sorted(set(g) & set(a) & set(b)):
        if len(g[k]) != len(a[k]) or len(a[k]) != len(b[k]):
            tot['SKIP'] += 1
            continue
        for f in range(len(FIELDS)):
            gv = sorted(x[f] for x in g[k])
            av = sorted(x[f] for x in a[k])
            bv = sorted(x[f] for x in b[k])
            ag, bg = av == gv, bv == gv
            if ag and bg:
                tot['EQ'] += 1
            elif bg:
                tot['TO'] += 1
            elif ag:
                tot['AWAY'] += 1
                tot['MWRONG'] += 1
                ex.append(('AWAY', k, FIELDS[f], gv, av, bv))
            else:
                tot['STILL'] += 1
                if av != bv:
                    tot['MWRONG'] += 1
                    ex.append(('MOVED-WRONG', k, FIELDS[f], gv, av, bv))
    print('  VIEW-KEYED  ' + '  '.join(f'{k}={v}' for k, v in tot.items())
          + f'  keys={len(set(g) & set(a) & set(b))}')
    for e in ex[:12]:
        print('   ', e)


main()
