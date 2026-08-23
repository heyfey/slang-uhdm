#!/usr/bin/env python3
# r10earl76 — ORDER-FREE MULTISET scorer (r10v75repro/vscore75.py, unchanged in
# substance and kept deliberately: a sorted-list INDEX pairing manufactures
# phantom AWAY cells and can HIDE a real one).  Every key is scored as a
# MULTISET DISTANCE to golden, so a KIND FLIP at one key is one cell.
#   usage: score76.py <gold.n> <pristine.n> <patched.n> [maxdetail] [--judged]
#
# `--judged` drops the `actval=` token from every payload before scoring.  It is
# there because `enum_const::Compare`
# (~/git-repos/UHDM/build/generated/src/enum_const.cpp) reads VpiType, VpiName,
# VpiDefName, VpiDecompile and VpiSize and NEVER VpiValue: an `INT:` / `UINT:`
# prefix difference on a bound enum_const is INVISIBLE TO THE JUDGE.  Run the
# scorer BOTH ways and report both numbers — the default (everything scored) is
# the conservative one and is what catches a real flip; `--judged` is what the
# official uhdm-cmp can actually see.
import sys
from collections import Counter, defaultdict

def load(p):
    d = defaultdict(Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        k, _, pay = ln.partition(' ')
        if '--judged' in sys.argv[1:]:
            pay = ' '.join(t for t in pay.split() if not t.startswith('actval='))
        d[k][pay] += 1
    return d

JUDGED = '--judged' in sys.argv[1:]
ARGS = [a for a in sys.argv[1:] if not a.startswith('--')]
G, O, Q = load(ARGS[0]), load(ARGS[1]), load(ARGS[2])
MX = int(ARGS[3]) if len(ARGS) > 3 else 12

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
