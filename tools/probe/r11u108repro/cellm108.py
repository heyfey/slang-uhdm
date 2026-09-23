#!/usr/bin/env python3
"""cellm108.py <arms-root> <tagA> <tagB> [arm ...]
Per-CELL scorer for § defPkgMemberTdOfNamedShares108, keyed by
<pkg>|<struct>|<member> (cenm108 lines, DEF package listing).  A cell's value
is the SET of typespec shapes reachable under that key (the listener can reach
a member twice through two listings; the set is compared whole, never a
last-writer dict).  TO-GOLDEN / AWAY / STILL-WRONG / UNMOVED as cell108.py."""
import os, subprocess, sys, collections
root, ta, tb = sys.argv[1:4]
arms = sys.argv[4:] or sorted(os.listdir(root))
CEN = os.environ.get('CEN', '/tmp/r11u108_tools/cenm108')
def cells(p):
    if not os.path.exists(p): return None
    out = subprocess.run([CEN, p], capture_output=True, text=True, timeout=600).stdout
    d = collections.defaultdict(set)
    for l in out.splitlines():
        k, v = l.split(' ', 1)
        d[k].add(v)
    return d
tot = collections.Counter()
for a in arms:
    w = os.path.join(root, a)
    if not os.path.isdir(w): continue
    g, x, y = (cells(os.path.join(w, t + '.uhdm')) for t in ('gold', ta, tb))
    if g is None or x is None or y is None:
        print(f'{a} SKIP (missing db)'); continue
    for n in sorted(set(g) | set(x) | set(y)):
        gv, xv, yv = g.get(n, set()), x.get(n, set()), y.get(n, set())
        if xv == yv:
            v = 'UNMOVED-OK' if xv == gv else 'UNMOVED-WRONG'
        elif yv == gv: v = 'TO-GOLDEN'
        elif xv == gv: v = 'AWAY'
        else:
            # The BINDING is the member typespec's kind + name; `elem=` is a
            # field INSIDE the bound object (a different cell, the next head).
            bind = lambda st: {v.split(' elem=')[0] for v in st}
            v = ('STILL-WRONG, BINDING TO-GOLDEN'
                 if bind(yv) == bind(gv) and bind(xv) != bind(gv)
                 else 'STILL-WRONG, BINDING AWAY' if bind(xv) == bind(gv)
                 else 'STILL-WRONG')
        tot[v] += 1
        if v not in ('UNMOVED-OK', 'UNMOVED-WRONG'):
            print(f'{a} {n} {v} gold={sorted(gv)} {ta}={sorted(xv)} {tb}={sorted(yv)}')
print('TOTALS', dict(tot))
