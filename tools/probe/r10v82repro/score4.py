#!/usr/bin/env python3
"""v82 verifier — SLOT-LEVEL regression detector.  For each span, the multiset
intersection with golden is the set of slots we got RIGHT.  A slot that pristine
got right and the patched binary no longer gets right is a REGRESSION, even when
the span-level verdict reads MOVED-WRONG because other slots improved.
usage: score4.py <g.cen> <o.cen> <q.cen> [--parent KIND]
"""
import sys, collections

def load(fn, parent=None):
    d = collections.defaultdict(collections.Counter)
    for line in open(fn):
        if line.startswith('#') or not line.strip():
            continue
        f = line.rstrip('\n').split('\t')
        cnt = int(f[0]); span = f[1]; par = f[2]
        if parent and par != parent:
            continue
        d[span][tuple(f[2:])] += cnt
    return d

par = sys.argv[sys.argv.index('--parent')+1] if '--parent' in sys.argv else None
g, o, q = (load(sys.argv[i], par) for i in (1,2,3))
lost = gained = 0
for s in sorted(set(g) | set(o) | set(q)):
    G, O, Q = g.get(s, collections.Counter()), o.get(s, collections.Counter()), q.get(s, collections.Counter())
    ro, rq = G & O, G & Q          # slots each binary matches golden on
    l, gn = ro - rq, rq - ro
    if l:
        lost += sum(l.values()); print(f"LOST-GOLDEN-SLOT {s}  {dict(l)}")
    if gn:
        gained += sum(gn.values()); print(f"GAINED-GOLDEN-SLOT {s}  {dict(gn)}")
print(f"# LOST={lost} GAINED={gained}")
