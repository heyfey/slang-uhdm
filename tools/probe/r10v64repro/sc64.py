#!/usr/bin/env python3
"""r10v64 — 3-way MULTISET score of cen64 censuses (golden/pristine/patched).
Buckets per (key, payload-slot): TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG /
STILL-RIGHT / STILL-WRONG / GOLDEN-ONLY / OURS-ONLY.  MEASUREMENT ONLY."""
import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p, errors='replace').read().splitlines():
        k, _, v = ln.partition(' || ')
        d[k].append(v)
    for k in d: d[k].sort()
    return d
g, o, p = (load(x) for x in sys.argv[1:4])
top = int(sys.argv[4]) if len(sys.argv) > 4 else 20
b = collections.Counter(); ex = collections.defaultdict(list)
for k in set(g) | set(o) | set(p):
    G, O, P = g.get(k, []), o.get(k, []), p.get(k, [])
    n = max(len(G), len(O), len(P))
    for i in range(n):
        gv = G[i] if i < len(G) else None
        ov = O[i] if i < len(O) else None
        pv = P[i] if i < len(P) else None
        if gv is None:
            b['OURS-ONLY']  += 1
            if ov is None and pv is not None: b['OURS-ONLY-NEW'] += 1; ex['OURS-ONLY-NEW'].append((k, gv, ov, pv))
            continue
        if ov is None and pv is None: b['GOLDEN-ONLY'] += 1; continue
        ro, rp = (ov == gv), (pv == gv)
        if ro and rp: b['STILL-RIGHT'] += 1
        elif not ro and rp: b['TO-GOLDEN'] += 1; ex['TO-GOLDEN'].append((k, gv, ov, pv))
        elif ro and not rp: b['AWAY-GOLDEN'] += 1; ex['AWAY-GOLDEN'].append((k, gv, ov, pv))
        elif ov == pv: b['STILL-WRONG'] += 1
        else: b['MOVED-WRONG'] += 1; ex['MOVED-WRONG'].append((k, gv, ov, pv))
print(' '.join('%s=%d' % (x, b[x]) for x in
      ('TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG','STILL-RIGHT','STILL-WRONG','GOLDEN-ONLY','OURS-ONLY','OURS-ONLY-NEW')))
for bucket in ('AWAY-GOLDEN','OURS-ONLY-NEW','MOVED-WRONG','TO-GOLDEN'):
    for k, gv, ov, pv in ex[bucket][:top]:
        print('%-12s %s\n    G: %s\n    O: %s\n    P: %s' % (bucket, k, gv, ov, pv))
