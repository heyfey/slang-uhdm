#!/usr/bin/env python3
"""r10uvm203 — the DIRECTION scorer.  MEASUREMENT ONLY.
For one (golden, pristine, patched) cell-file triple, classify EVERY key:
  RIGHT->RIGHT / RIGHT->WRONG / WRONG->RIGHT / WRONG->WRONG-CLOSER /
  WRONG->WRONG / ONLY-OURS gained.
RIGHT->WRONG (a cell that agreed with golden and no longer does) and any NEW
ONLY-OURS key are the two verdicts that fail the pass.
usage: dir203.py <golden.cells> <pristine.cells> <patched.cells>
"""
import sys
from collections import Counter

def load(p):
    d = {}
    with open(p) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line: continue
            k, _, v = line.rpartition('\t')
            d.setdefault(k, Counter())[v] += 1
    return d

g, a, b = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
def state(k):
    gv = g.get(k)
    def cls(o):
        ov = o.get(k)
        if gv is None:  return 'ONLY-OURS' if ov is not None else 'ABSENT'
        if ov is None:  return 'MISSING'
        return 'RIGHT' if gv == ov else 'WRONG'
    return cls(a), cls(b)
keys = set(g) | set(a) | set(b)
c = Counter()
bad = []
for k in sorted(keys):
    s0, s1 = state(k)
    c[(s0, s1)] += 1
    if s0 == 'RIGHT' and s1 != 'RIGHT': bad.append(('RIGHT->'+s1, k))
    if s0 != 'ONLY-OURS' and s1 == 'ONLY-OURS': bad.append(('NEW-ONLY-OURS', k))
for (s0, s1), n in sorted(c.items()):
    if s0 != s1 or s1 != 'RIGHT':
        print('%-10s -> %-10s %d' % (s0, s1, n))
print('RIGHT->RIGHT %d' % c[('RIGHT','RIGHT')])
print('-- MOVED-WRONG=%d' % len(bad))
for t, k in bad[:40]:
    print('   %s\t%s' % (t, k))
