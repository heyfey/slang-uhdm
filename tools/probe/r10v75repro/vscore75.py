#!/usr/bin/env python3
# r10v75 (VERIFIER) — ORDER-FREE MULTISET scorer.  Deliberately NOT the
# sorted-list index pairing of r10earl75repro/score75.py (a sorted pairing
# manufactures phantom AWAY cells and can HIDE a real one — the vmsjoin74
# lesson): every key is scored as a MULTISET DISTANCE to golden.
#   usage: vscore75.py <gold.n> <pristine.n> <patched.n> [maxdetail]
import sys
from collections import Counter, defaultdict

def load(p):
    d = defaultdict(Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        k, _, pay = ln.partition(' ')
        d[k][pay] += 1
    return d

G, O, Q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
MX = int(sys.argv[4]) if len(sys.argv) > 4 else 12

def dist(a, b):
    return sum((a - b).values()) + sum((b - a).values())

tot = Counter()
det = defaultdict(list)
for k in set(G) | set(O) | set(Q):
    g, o, q = G.get(k, Counter()), O.get(k, Counter()), Q.get(k, Counter())
    dO, dQ = dist(o, g), dist(q, g)
    if o == q:
        tot['STILL-RIGHT' if dQ == 0 else 'STILL-WRONG'] += 1
        if dQ: det['STILL-WRONG'].append((k, dict(g), dict(q)))
        continue
    # the cell MOVED
    if not g:
        tot['NOGOLD-MOVED'] += 1
        det['NOGOLD-MOVED'].append((k, dict(o), dict(q)))
    elif dQ < dO and dQ == 0:
        tot['TO-GOLDEN'] += 1; det['TO-GOLDEN'].append((k, dict(g), dict(q)))
    elif dQ < dO:
        tot['TOWARD-NOT-EQUAL'] += 1; det['TOWARD-NOT-EQUAL'].append((k, dict(g), dict(q)))
    elif dQ > dO and dO == 0:
        tot['AWAY-GOLDEN'] += 1; det['AWAY-GOLDEN'].append((k, dict(g), dict(q)))
    elif dQ > dO:
        tot['MOVED-WRONG'] += 1; det['MOVED-WRONG'].append((k, dict(g), dict(q)))
    else:
        tot['MOVED-SIDEWAYS'] += 1; det['MOVED-SIDEWAYS'].append((k, dict(g), dict(q)))
print('keys', sum(tot.values()), dict(tot))
for t in ('AWAY-GOLDEN', 'MOVED-WRONG', 'MOVED-SIDEWAYS', 'NOGOLD-MOVED',
          'TOWARD-NOT-EQUAL', 'TO-GOLDEN'):
    for k, a, b in det[t][:MX]:
        print(' ', t, k, '| G/O', a, '| Q', b)
