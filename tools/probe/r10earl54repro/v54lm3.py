#!/usr/bin/env python3
"""WHOLE-DUMP three-way LINE-MULTISET regression detector.

census54.scan reads ONLY port-HighConn slots, so it is structurally blind to a
change anywhere else in the database -- a package parameter's own declaration,
a cont-assign RHS, a def-view listing.  This reads EVERY line of all three
dumps.  For each normalised line text it compares multiplicities:

  BROKE  count(pristine) == count(golden) and count(patched) != count(golden)
  FIXED  count(patched)  == count(golden) and count(pristine) != count(golden)
  BOTH   neither side matches golden (a residue reshaped)

Object ids are stripped (they are allocation order, never compared by uhdm-cmp).
  usage: lm3.py <g.dump> <pris.dump> <pat.dump> <label>
"""
import re, sys
from collections import Counter
def load(p):
    c = Counter()
    for l in open(p, errors='replace'):
        l = re.sub(r', id:\d+', '', l.strip())
        l = re.sub(r'file:[^,]*,', 'file:*,', l)
        c[l] += 1
    return c
g, pr, pa, lab = (load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3]), sys.argv[4])
broke, fixed, both = [], [], []
for k in set(g) | set(pr) | set(pa):
    G, P, A = g[k], pr[k], pa[k]
    if P == A: continue
    if P == G and A != G: broke.append((k, G, P, A))
    elif A == G and P != G: fixed.append((k, G, P, A))
    else: both.append((k, G, P, A))
print('%-18s BROKE=%d FIXED=%d RESHAPED=%d' % (lab, len(broke), len(fixed), len(both)))
for tag, lst in (('BROKE', broke), ('RESHAPED', both)):
    for k, G, P, A in sorted(lst):
        print('   %-8s g=%d pris=%d pat=%d  %s' % (tag, G, P, A, k.strip()[:110]))
