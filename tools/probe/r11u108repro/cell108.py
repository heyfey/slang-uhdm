#!/usr/bin/env python3
"""cell108.py <arms-root> <tagA> <tagB> [arm ...]
Per-CELL scorer for § tpPackedArrayTsVar108, keyed by variable NAME.
A cell is the cen108 line for one variable (kind, expr, ranges, elems).
For each arm with gold.uhdm, A and B databases: TO-GOLDEN (A!=gold, B==gold),
AWAY (A==gold, B!=gold), STILL-WRONG (A!=gold, B!=gold, A!=B), UNMOVED.
Cells present on one side only are reported as ONLY-<side>.  Multiset-safe:
a name that appears twice on a side is reported DUP and never scored."""
import os, subprocess, sys, collections
root, ta, tb = sys.argv[1:4]
arms = sys.argv[4:] or sorted(os.listdir(root))
CEN = os.environ.get('CEN', '/tmp/r11u108_tools/cen108')
def cells(p):
    if not os.path.exists(p): return None
    out = subprocess.run([CEN, p], capture_output=True, text=True, timeout=600).stdout
    d = collections.defaultdict(list)
    for l in out.splitlines():
        f = l.split(' ')
        d[f[1]].append((f[0],) + tuple(f[2:]))
    return d
tot = collections.Counter()
for a in arms:
    w = os.path.join(root, a)
    g, x, y = (cells(os.path.join(w, t + '.uhdm')) for t in ('gold', ta, tb))
    if g is None or x is None or y is None:
        print(f'{a} SKIP (missing db)'); continue
    for n in sorted(set(g) | set(x) | set(y)):
        gv, xv, yv = g.get(n), x.get(n), y.get(n)
        if any(v and len(v) > 1 for v in (gv, xv, yv)):
            v = 'DUP'
        elif gv is None:
            v = 'UNMOVED-NOGOLD' if xv == yv else 'MOVED-NOGOLD'
        elif xv == yv:
            v = 'UNMOVED-OK' if xv == gv else 'UNMOVED-WRONG'
        elif yv == gv:
            v = 'TO-GOLDEN'
        elif xv == gv:
            v = 'AWAY'
        else:
            v = 'STILL-WRONG'
        tot[v] += 1
        if v not in ('UNMOVED-OK',):
            print(f'{a} {n} {v} gold={gv} {ta}={xv} {tb}={yv}')
print('TOTALS', dict(tot))
