#!/usr/bin/env python3
"""r10v96 -- REGRESSION DETECTOR.  Per-KEY multiset intersection with golden,
pristine vs patched.  Prints any key where the patched side matches FEWER
golden rows than the pristine side (a RIGHT->WRONG), and the reverse.
MEASUREMENT ONLY."""
import sys, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln: continue
        parts = ln.split('\t')
        d['\t'.join(parts[:4])][parts[4] if len(parts) > 4 else ''] += 1
    return d
g, a, b = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
worse = better = 0
for k in set(g) | set(a) | set(b):
    gc = g.get(k, collections.Counter())
    ia = sum((gc & a.get(k, collections.Counter())).values())
    ib = sum((gc & b.get(k, collections.Counter())).values())
    if ib < ia:
        worse += ia - ib
        print('WORSE  %s  golden=%s pris=%s patc=%s' % (k, sorted(gc.items()), sorted(a.get(k,{}).items()), sorted(b.get(k,{}).items())))
    elif ib > ia:
        better += ib - ia
print('RIGHT->WRONG %d   WRONG->RIGHT %d' % (worse, better))
