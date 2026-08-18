#!/usr/bin/env python3
# r10earl64 — 3-WAY keyed MULTISET join of three excen64/pacen64 censuses
# (golden / pristine / patched) bucketing every cell TO-GOLDEN, AWAY-GOLDEN,
# MOVED-WRONG, STILL-RIGHT, STILL-WRONG.  MEASUREMENT ONLY.
#   usage: score64.py <gold> <pristine> <patched> [key-field-count]
# Keys are the leading <n> whitespace fields (default 5: tag sec owner site
# path); the payload is the rest of the line.  A MULTISET join, never a
# last-writer dict (RESUME §9: keys collide).
import sys
from collections import defaultdict, Counter
NK = int(sys.argv[4]) if len(sys.argv) > 4 else 5
def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        d[' '.join(f[:NK])].append(' '.join(f[NK:]))
    return d
g, o, q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
b = Counter(); ex = defaultdict(list)
for k in set(g) | set(o) | set(q):
    G, O, Q = sorted(g.get(k, [])), sorted(o.get(k, [])), sorted(q.get(k, []))
    n = max(len(G), len(O), len(Q))
    G += ['<none>'] * (n - len(G)); O += ['<none>'] * (n - len(O)); Q += ['<none>'] * (n - len(Q))
    for i in range(n):
        pr, pa, gd = O[i], Q[i], G[i]
        if pr == pa:
            b['STILL-RIGHT' if pa == gd else 'STILL-WRONG'] += 1
            if pa != gd: ex['STILL-WRONG'].append((k, gd, pa))
            continue
        if pa == gd: b['TO-GOLDEN'] += 1; ex['TO-GOLDEN'].append((k, gd, pa))
        elif pr == gd: b['AWAY-GOLDEN'] += 1; ex['AWAY-GOLDEN'].append((k, gd, pa))
        else: b['MOVED-WRONG'] += 1; ex['MOVED-WRONG'].append((k, gd, pa))
print('cells', sum(b.values()), dict(b))
for t in ('AWAY-GOLDEN', 'MOVED-WRONG', 'TO-GOLDEN'):
    for k, gd, pa in ex[t][:int(sys.argv[5]) if len(sys.argv) > 5 else 6]:
        print(' ', t, k, '| G', gd, '| P', pa)
