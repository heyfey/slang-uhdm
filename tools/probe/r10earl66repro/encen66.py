#!/usr/bin/env python3
# r10earl66 — every OURS cell that is a ref_obj to an enum_const, keyed, with
# what GOLDEN has at the same key.  MEASUREMENT ONLY.
import sys, re
from collections import defaultdict, Counter
def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        d[' '.join(f[:5])].append(' '.join(f[5:]))
    return d
g, o = load(sys.argv[1]), load(sys.argv[2])
c = Counter(); rows = defaultdict(list)
for k in set(o):
    kf = k.split(' '); sec, site, path = kf[1], kf[3], kf[4]
    st = 'HC' if site.startswith('HC') else ('CA' if site.startswith('CA') else ('PA' if site.startswith('PA') else 'VAR'))
    tail = re.sub(r'\[\d+\]', '[]', path.split('/')[-1])
    G, O = sorted(g.get(k, [])), sorted(o.get(k, []))
    n = max(len(G), len(O)); G += ['<none>']*(n-len(G)); O += ['<none>']*(n-len(O))
    for i in range(n):
        if 'actual=enum_const' not in O[i]: continue
        gk = G[i].split(' ')[0]
        same = 'SAME' if G[i]==O[i] else 'DIFF'
        c[(sec, st, tail, gk, same)] += 1
        rows[(sec, st, tail, gk, same)].append((k, G[i], O[i]))
for kk, n in c.most_common():
    print(f'{n:6d} sec={kk[0]:5s} site={kk[1]:4s} pos={kk[2]:12s} GOLDEN={kk[3]:12s} {kk[4]}')
print('TOTAL ours-ref-to-enum_const cells', sum(c.values()))
if len(sys.argv)>3:
    sel=sys.argv[3]
    for kk,rr in rows.items():
        if '|'.join(map(str,kk))==sel:
            for r in rr[:int(sys.argv[4]) if len(sys.argv)>4 else 10]: print('  ', r[0], '| G', r[1], '| O', r[2])
