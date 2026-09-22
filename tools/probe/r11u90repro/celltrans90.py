#!/usr/bin/env python3
"""r11u90 PER-CELL TRANSITION MATRIX — the arbiter the landing bar asks for.

`cacell90.py` scores one pair of dumps per cell.  This runs it on the PRISTINE
pair and on the PATCHED pair of the SAME arm, keys the two readings by the
same cell key, and prints the transition matrix over every cell of every arm.

The bar: `MATCH -> anything else` must be ZERO (no cell that agreed with
golden may stop agreeing), and every transition out of DIFF / OURS-ONLY /
GOLD-ONLY must be INTO `MATCH` or into a state no further from golden.  A cell
present on one side only (an arm whose cell count changed) is reported as
`<absent>` on that side and named, never rounded away.

usage: GRID=<dir> celltrans90.py <tagA> <tagB>
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GRID = os.environ['GRID']
TA, TB = sys.argv[1], sys.argv[2]


def score(arm, tag):
    g = os.path.join(GRID, arm, f'gold.{tag}.dump')
    o = os.path.join(GRID, arm, f'ours.{tag}.dump')
    if not (os.path.exists(g) and os.path.exists(o)):
        return None
    p = subprocess.run([sys.executable, os.path.join(HERE, 'cacell90.py'),
                        g, o, '--rows'], capture_output=True, text=True)
    out = {}
    for l in p.stdout.split('\n'):
        t = l.split(None, 1)
        if len(t) != 2 or t[0] not in ('MATCH', 'DIFF', 'GOLD-ONLY',
                                       'OURS-ONLY', 'UNSCORED'):
            continue
        key = t[1].split(')')[0] + ')'
        out[key] = t[0]
    return out


mat = {}
named = []
for arm in sorted(os.listdir(GRID)):
    a = score(arm, TA)
    b = score(arm, TB)
    if a is None or b is None:
        if a is not None or b is not None:
            named.append((arm, 'ARM-DUMPS-ONE-SIDED', '', ''))
        continue
    for k in sorted(set(a) | set(b)):
        va, vb = a.get(k, '<absent>'), b.get(k, '<absent>')
        mat[(va, vb)] = mat.get((va, vb), 0) + 1
        if va != vb:
            named.append((arm, k, va, vb))

print(f'PER-CELL TRANSITIONS {TA} -> {TB}')
for (va, vb), n in sorted(mat.items(), key=lambda x: -x[1]):
    flag = '  <== BAR' if va == 'MATCH' and vb != 'MATCH' else ''
    print(f'  {va:12s} -> {vb:12s} {n:5d}{flag}')
bad = sum(n for (va, vb), n in mat.items() if va == 'MATCH' and vb != 'MATCH')
print(f'MOVED-WRONG (MATCH -> non-MATCH) = {bad}')
print('NAMED TRANSITIONS:')
for arm, k, va, vb in named:
    print(f'  {arm:22s} {va:10s} -> {vb:10s} {k}')
