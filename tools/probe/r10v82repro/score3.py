#!/usr/bin/env python3
"""v82 verifier — SPAN-KEYED 3-WAY SCORE (golden / pristine / patched).
Payload is JUDGE-VISIBLE ONLY (decompile, size, value, consttype) plus the
parent kind; the span is the KEY, never scored.  Multiset per span.
usage: score3.py <g.cen> <o.cen> <q.cen> [--parent KIND]
Each .cen is cencon82.py output (count \t span \t parent \t dec \t size \t val \t ct)
"""
import sys, collections

def load(fn, parent=None):
    d = collections.defaultdict(collections.Counter)
    for line in open(fn):
        if line.startswith('#') or not line.strip():
            continue
        f = line.rstrip('\n').split('\t')
        cnt = int(f[0]); span = f[1]; par = f[2]; payload = tuple(f[2:])
        if parent and par != parent:
            continue
        d[span][payload] += cnt
    return d

g, o, q = (load(sys.argv[i], (sys.argv[sys.argv.index('--parent')+1] if '--parent' in sys.argv else None)) for i in (1,2,3))
spans = sorted(set(g) | set(o) | set(q))
tally = collections.Counter()
for s in spans:
    G, O, Q = g.get(s, collections.Counter()), o.get(s, collections.Counter()), q.get(s, collections.Counter())
    if O == G and Q == G: v = 'UNMOVED-RIGHT'
    elif O == G and Q != G: v = 'AWAY-GOLDEN'
    elif O != G and Q == G: v = 'TO-GOLDEN'
    elif O == Q: v = 'UNMOVED-WRONG'
    else: v = 'MOVED-WRONG'
    tally[v] += 1
    if v in ('AWAY-GOLDEN', 'TO-GOLDEN', 'MOVED-WRONG'):
        print(f"{v}\t{s}\n\tG={dict(G)}\n\tO={dict(O)}\n\tQ={dict(Q)}")
print('# ' + '  '.join(f"{k}={v}" for k, v in sorted(tally.items())))
