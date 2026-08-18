#!/usr/bin/env python3
# v65 verifier — independent MULTISET keyed join, compare-visible payload only.
import sys
from collections import defaultdict, Counter
NK = 5
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
    G += ['<none>']*(n-len(G)); O += ['<none>']*(n-len(O)); Q += ['<none>']*(n-len(Q))
    for i in range(n):
        pr, pa, gd = O[i], Q[i], G[i]
        if pr == pa:
            t = 'STILL-RIGHT' if pa == gd else 'STILL-WRONG'
        elif pa == gd: t = 'TO-GOLDEN'
        elif pr == gd: t = 'AWAY-GOLDEN'
        else: t = 'MOVED-WRONG'
        b[t] += 1
        if t != 'STILL-RIGHT': ex[t].append((k, gd, pr, pa))
print(dict(b))
for t in ('AWAY-GOLDEN','MOVED-WRONG','TO-GOLDEN'):
    for k,gd,pr,pa in ex[t][:12]:
        print('   ', t, k, '\n      G:', gd, '\n      O:', pr, '\n      P:', pa)
