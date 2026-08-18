#!/usr/bin/env python3
"""v60 VERIFIER 3-way attribution — payload restricted to the fields the
generated `typespec::Compare` / `ref_typespec::Compare` ACTUALLY READ
(kind, ref name, typedef_alias kind, Instance kind+name).  SPANS ARE DROPPED:
Compare never reads VpiLineNo, so a span-only difference is not a defect and,
more importantly, a span-only difference must not BURY an Instance flip in the
STILL-WRONG bucket (which is exactly what it did in the implementer's own
attr60.py on the untyped-package-member cells)."""
import re, sys, collections
def load(p):
    c = collections.Counter()
    for l in open(p):
        f = l.rstrip('\n').split('\t')
        if f[0] != 'ALLOBJ': continue
        k = (f[1], re.sub(r'^[^:]*:', '', f[3]))
        v = (f[4], f[5], f[6], f[8], f[9], f[10])   # NO span
        c[(k, v)] += 1
    return c
G, P, A = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
keys = collections.defaultdict(lambda: [collections.Counter(), collections.Counter(), collections.Counter()])
for i, c in enumerate((G, P, A)):
    for (k, v), n in c.items(): keys[k][i][v] += n
b = collections.Counter(); rows = collections.Counter()
for k, (g, p, a) in keys.items():
    if p == a == g: b['UNMOVED-GOOD'] += 1
    elif p != g and a == g: b['TO-GOLDEN'] += 1; rows[('TO-GOLDEN', k[1], tuple(sorted(g)), tuple(sorted(p)), tuple(sorted(a)))] += 1
    elif p == g and a != g: b['AWAY-GOLDEN'] += 1; rows[('AWAY-GOLDEN', k[1], tuple(sorted(g)), tuple(sorted(p)), tuple(sorted(a)))] += 1
    elif p == a: b['UNMOVED-BAD'] += 1
    else: b['STILL-WRONG'] += 1; rows[('STILL-WRONG', k[1], tuple(sorted(g)), tuple(sorted(p)), tuple(sorted(a)))] += 1
print('keys(union)=%d' % len(keys), dict(b))
for kk, n in rows.most_common(60):
    if kk[0] == 'TO-GOLDEN' and len(sys.argv) < 5: continue
    print('%-12s %-14s n=%-3d\n   gold=%s\n   pris=%s\n   patc=%s' % (kk[0], kk[1], n, kk[2], kk[3], kk[4]))
