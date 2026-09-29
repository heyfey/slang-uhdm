#!/usr/bin/env python3
# (v11u227) recaway.py <golden.rec> <pristine.rec> <law.rec>: for every walk index where the pristine and law records
# differ (the two walks must have the same length, else WALK_SHAPE_DIFFERS), a record is AWAY when pristine's record is
# in golden's record multiset and law's is not, TOWARD for the reverse, OTHER otherwise (both absent or both present).
import sys
from collections import Counter
def rd(p):
    try:
        return open(p, errors='replace').read().splitlines()
    except FileNotFoundError:
        return None
g, a, b = (rd(x) for x in sys.argv[1:4])
if g is None or a is None or b is None:
    print('NO_RECORDS'); sys.exit(0)
if len(a) != len(b):
    print('WALK_SHAPE_DIFFERS p=%d l=%d' % (len(a), len(b))); sys.exit(0)
G = Counter(g)
away, tow, oth = [], [], []
for i in range(len(a)):
    if a[i] == b[i]:
        continue
    ia, ib = G[a[i]] > 0, G[b[i]] > 0
    (away if ia and not ib else tow if ib and not ia else oth).append(i)
print('moved=%d away=%d toward=%d other=%d' % (len(away) + len(tow) + len(oth), len(away), len(tow), len(oth)))
for i in away[:8]:
    print('  AWAY #%d pristine: %s' % (i + 1, a[i]))
    print('            law: %s' % b[i])
