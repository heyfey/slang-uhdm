#!/usr/bin/env python3
"""r10v138 — three-way arm score from cen138 censuses.  LHS IS ALWAYS GOLDEN.
Multiset join on (VIEW, SITE, SPAN); payload = KIND|FIELDS.
TOGOLD  pristine wrong -> patched right
MOVWRNG pristine right -> patched wrong      <-- the thing that kills a pass
AWAY    wrong before and after but CHANGED
SAMEWR  wrong both, unchanged
SAMEOK  right both
Prints one-sided sets in BOTH directions (a multiset join drops unmatched)."""
import sys, collections

def load(p):
    m = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 6 or f[0] != 'CELL': continue
        m[(f[1], f[2], f[3])].append(f[4] + '|' + f[5])
    for k in m: m[k].sort()
    return m

g, o, q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
filt = sys.argv[4] if len(sys.argv) > 4 else ''
keys = sorted(set(g) | set(o) | set(q))
cnt = collections.Counter()
rows = []
for k in keys:
    if filt and filt not in k[1]: continue
    G, O, Q = g.get(k, []), o.get(k, []), q.get(k, [])
    po, pq = (O == G), (Q == G)
    if po and pq: t = 'SAMEOK'
    elif not po and pq: t = 'TOGOLD'
    elif po and not pq: t = 'MOVWRNG'
    elif O == Q: t = 'SAMEWR'
    else: t = 'AWAY'
    cnt[t] += 1
    if t != 'SAMEOK':
        rows.append((t, k, G, O, Q))
for t, k, G, O, Q in rows:
    print('%-8s %s | %s | %s' % (t, k[0], k[1], k[2]))
    print('         GOLD %s' % (G or ['<absent>'],))
    print('         PRIS %s' % (O or ['<absent>'],))
    print('         PATC %s' % (Q or ['<absent>'],))
print('SUMMARY TOGOLD=%d MOVWRNG=%d AWAY=%d SAMEWR=%d SAMEOK=%d' %
      (cnt['TOGOLD'], cnt['MOVWRNG'], cnt['AWAY'], cnt['SAMEWR'], cnt['SAMEOK']))
