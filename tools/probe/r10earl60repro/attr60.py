#!/usr/bin/env python3
"""r10earl60 — 3-WAY ATTRIBUTION over the ALLOBJ param_assign census.

golden / pristine / patched, keyed on a POSITION that exists identically on all
three sides -- the Lhs parameter's vpiFullName plus the param_assign's
line:col span -- with the Rhs's typespec target as the payload.

Multiset, not a dict: a key can repeat (orphan clones of one param_assign live
in the arena tail), and collapsing them would hide a cell.  Every bucket is
printed; nothing is dropped silently.

  UNMOVED-GOOD  pristine == patched == golden
  TO-GOLDEN     pristine != golden, patched == golden
  AWAY-GOLDEN   pristine == golden, patched != golden      <== the one that must be 0
  STILL-WRONG   pristine != golden, patched != golden, and patched != pristine
  UNMOVED-BAD   pristine == patched != golden
"""
import re, sys, collections
def nospan(s): return re.sub(r'^[^:]*:', '', s)
def load(p):
    c = collections.Counter()
    for l in open(p):
        f = l.rstrip('\n').split('\t')
        if f[0] != 'ALLOBJ': continue
        # key: Lhs fullname + param_assign span (file stripped: our VpiFile is
        # empty on many objects and Compare never reads it).
        k = (f[1], nospan(f[3]))
        # payload: Rhs kind, actual ts kind, actual ts span, ts Instance kind+name
        v = (f[4], f[6], nospan(f[7]), f[8], f[9])
        c[(k, v)] += 1
    return c
G, P, A = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
keys = collections.defaultdict(lambda: [collections.Counter(), collections.Counter(), collections.Counter()])
for i, c in enumerate((G, P, A)):
    for (k, v), n in c.items(): keys[k][i][v] += n
b = collections.Counter(); rows = collections.Counter()
for k, (g, p, a) in keys.items():
    if p == a == g: b['UNMOVED-GOOD'] += 1
    elif p != g and a == g: b['TO-GOLDEN'] += 1; rows[('TO-GOLDEN', k[1], tuple(sorted(g)), tuple(sorted(p)))] += 1
    elif p == g and a != g: b['AWAY-GOLDEN'] += 1; rows[('AWAY-GOLDEN', k[1], tuple(sorted(g)), tuple(sorted(a)))] += 1
    elif p == a: b['UNMOVED-BAD'] += 1
    else: b['STILL-WRONG'] += 1; rows[('STILL-WRONG', k[1], tuple(sorted(g)), tuple(sorted(a)))] += 1
print('keys(union)=%d' % len(keys), dict(b))
for kk, n in rows.most_common(40):
    print('%-12s %-14s n=%-4d gold=%s\n%38s ours=%s' % (kk[0], kk[1], n, kk[2], '', kk[3]))
