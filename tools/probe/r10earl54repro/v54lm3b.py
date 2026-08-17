#!/usr/bin/env python3
"""lm3 restricted to the DESIGN (everything BEFORE `\\_weaklyReferenced:`).

The tail is an UNORDERED ORPHAN LISTING -- UHDM parks there any object reachable
only through a weak link (a folded constant's loc-less int_typespec, and the
vpiParent chain that makes it printable).  GOLDEN HAS THE SAME TAIL AND GROWS IT
FOR THE SAME REASON, so tail multiplicities are not a regression signal; mixing
them into a whole-file multiset manufactures BROKE lines out of back-references.
"""
import re, sys
from collections import Counter
def load(p):
    c = Counter()
    for l in open(p, errors='replace'):
        if '_weaklyReferenced:' in l: break
        l = re.sub(r', id:\d+', '', l.strip())
        c[re.sub(r'file:[^,]*,', 'file:*,', l)] += 1
    return c
g, pr, pa, lab = (load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3]), sys.argv[4])
broke, fixed, both = [], [], []
for k in set(g) | set(pr) | set(pa):
    G, P, A = g[k], pr[k], pa[k]
    if P == A: continue
    if P == G and A != G: broke.append((k, G, P, A))
    elif A == G and P != G: fixed.append((k, G, P, A))
    else: both.append((k, G, P, A))
print('%-18s DESIGN-ONLY BROKE=%d FIXED=%d RESHAPED=%d' % (lab, len(broke), len(fixed), len(both)))
for k, G, P, A in sorted(broke):
    print('   BROKE  g=%d pris=%d pat=%d  %s' % (G, P, A, k[:110]))
