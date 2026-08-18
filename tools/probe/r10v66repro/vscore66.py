#!/usr/bin/env python3
# r10v66 verifier — 3-way keyed MULTISET join (golden / pristine / patched) with
# a JUDGE-FIELDS-ONLY payload: every span=/tsspan= token is STRIPPED from the
# payload before scoring (RESUME §9 / earl60's attrv60 lesson).
# usage: vscore66.py <gold> <pris> <pat> [nkeys] [nshow]
import sys, re
from collections import defaultdict, Counter
NK = int(sys.argv[4]) if len(sys.argv) > 4 else 5
NS = int(sys.argv[5]) if len(sys.argv) > 5 else 40
SPAN = re.compile(r'(ts)?span=\S*')
def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        pay = ' '.join(x for x in f[NK:] if not SPAN.fullmatch(x))
        d[' '.join(f[:NK])].append(pay)
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
print('cells', sum(b.values()), dict(b))
for t in ('AWAY-GOLDEN', 'MOVED-WRONG', 'TO-GOLDEN', 'STILL-WRONG'):
    for k, gd, pr, pa in ex[t][:NS]:
        print(' ', t, k, '\n      G', gd, '\n      O', pr, '\n      P', pa)
