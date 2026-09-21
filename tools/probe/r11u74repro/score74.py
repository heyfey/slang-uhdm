#!/usr/bin/env python3
"""r11u74 CELL SCORER — joins the resolving shape lister's per-cell verdicts on
the PRISTINE and the PATCHED binary against the SAME golden dump, and prints
FIXED / BROKEN / STILL per arm.  BROKEN is the number that decides the pass:
a cell pristine agreed with golden on and the patched binary does not.

usage: score74.py <grid-dir> [pris-tag] [pat-tag]
"""
import os, subprocess, sys

GRID = sys.argv[1]
PTAG = sys.argv[2] if len(sys.argv) > 2 else 'pris'
QTAG = sys.argv[3] if len(sys.argv) > 3 else 'pat'
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import shapes74 as sh                                      # noqa: E402

os.environ['NOSPAN'] = '1'


def sig(v):
    if not v:
        return 'ABSENT'
    r = v['rhs']
    la = (v['lhs'] or {}).get('act', '-')
    if not r:
        return f'NORHS lhsact={la}'
    return (f"{r.get('kind')} {r.get('value')} sz={r.get('vpiSize')} "
            f"ct={r.get('vpiConstType')} dec={r.get('vpiDecompile')} "
            f"nm={r.get('name')} lhsact={la}")


tot = {'FIXED': 0, 'BROKEN': 0, 'STILL': 0, 'OK': 0}
for arm in sorted(os.listdir(GRID)):
    d = os.path.join(GRID, arm)
    g = os.path.join(d, f'gold.{QTAG}.dump')
    p = os.path.join(d, f'ours.{PTAG}.dump')
    q = os.path.join(d, f'ours.{QTAG}.dump')
    if not (os.path.isfile(g) and os.path.isfile(p) and os.path.isfile(q)):
        continue
    G = dict(sh.flat(g)); P = dict(sh.flat(p)); Q = dict(sh.flat(q))
    c = {'FIXED': 0, 'BROKEN': 0, 'STILL': 0, 'OK': 0}
    for k in set(G) | set(P) | set(Q):
        gs, ps, qs = sig(G.get(k)), sig(P.get(k)), sig(Q.get(k))
        if ps == gs and qs == gs:
            c['OK'] += 1
        elif ps != gs and qs == gs:
            c['FIXED'] += 1
        elif ps == gs and qs != gs:
            c['BROKEN'] += 1
            print(f'  BROKEN {arm} {k}\n     G: {gs}\n     P: {ps}\n     Q: {qs}')
        else:
            c['STILL'] += 1
    for k in c:
        tot[k] += c[k]
    print(f"{arm:16s} OK={c['OK']:4d} FIXED={c['FIXED']:3d} "
          f"BROKEN={c['BROKEN']:3d} STILL={c['STILL']:3d}")
print(f"TOTAL OK={tot['OK']} FIXED={tot['FIXED']} BROKEN={tot['BROKEN']} "
      f"STILL={tot['STILL']}")
