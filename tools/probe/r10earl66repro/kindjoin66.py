#!/usr/bin/env python3
# r10earl66 — MULTISET join keyed (tag sec owner site path); classify by
# (golden kind, ours kind) pair.  MEASUREMENT ONLY.
import sys
from collections import defaultdict, Counter
def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        d[' '.join(f[:5])].append(' '.join(f[5:]))
    return d
g, o = load(sys.argv[1]), load(sys.argv[2])
pairs = Counter(); ex = defaultdict(list)
for k in set(g) | set(o):
    G, O = sorted(g.get(k, [])), sorted(o.get(k, []))
    n = max(len(G), len(O))
    G += ['<none>']*(n-len(G)); O += ['<none>']*(n-len(O))
    for i in range(n):
        gk = G[i].split(' ')[0]; ok = O[i].split(' ')[0]
        if G[i] == O[i]: continue
        pairs[(gk, ok)] += 1
        ex[(gk, ok)].append((k, G[i], O[i]))
for (gk, ok), c in pairs.most_common(40):
    print(f'{c:6d}  G={gk:22s} O={ok}')
print('TOTAL differing cells', sum(pairs.values()))
if len(sys.argv) > 3:
    want = sys.argv[3]
    for (gk, ok), rows in ex.items():
        if f'{gk}>{ok}' == want:
            for r in rows[:int(sys.argv[4]) if len(sys.argv)>4 else 20]:
                print(' ', r[0], '| G', r[1], '| O', r[2])
