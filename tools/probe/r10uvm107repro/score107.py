#!/usr/bin/env python3
"""r10uvm107 — TO-GOLDEN / AWAY / STILL scorer over the reference-actual census.

MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS is ALWAYS golden.

    score107.py <golden.cen> <pristine.cen> <patched.cen> [label]

Cells are the census's own REF rows, keyed on (VIEW, OOB, OWNER, LC, NM) -- what
BOTH sides can spell -- and their value is the MULTISET of Actual_group kinds at
that key (a key can repeat when a database holds several copies of one body, and
a last-writer dict would drop those rows: RESUME §9's multiset-join trap).

    TO-GOLDEN  pristine != golden and patched == golden
    AWAY       pristine == golden and patched != golden
    STILL      both differ from golden (and the cell changed)
    UNMOVED    patched == pristine (printed only as a total)
Keys present on one side only are reported separately and never scored, because
a missing key is a naming/multiplicity difference, not a binding one.
"""
import sys, collections

def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) > 10 and f[1] == 'REF':
            d[(f[2], f[3], f[4], f[5], f[6])][f[7]] += 1
    return d

G, A, B = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
label = sys.argv[4] if len(sys.argv) > 4 else '-'
keys = set(G) & set(A) & set(B)
to_g = away = still = unmoved = 0
tg, aw = [], []
for k in keys:
    if B[k] == A[k]:
        unmoved += 1
        continue
    if A[k] != G[k] and B[k] == G[k]:
        to_g += 1; tg.append(k)
    elif A[k] == G[k] and B[k] != G[k]:
        away += 1; aw.append(k)
    else:
        still += 1
print('%s  cells=%d  TO-GOLDEN=%d  AWAY=%d  STILL-DIFFERENT=%d  UNMOVED=%d  '
      'golden-only-keys=%d ours-only-keys=%d'
      % (label, len(keys), to_g, away, still, unmoved,
         len(set(G) - set(B)), len(set(B) - set(G))))
for k in sorted(tg):
    print('   TO-GOLDEN %s %s %s %s %s : %s -> %s' %
          (k[0], k[1], k[2], k[3], k[4], dict(A[k]), dict(B[k])))
for k in sorted(aw):
    print('   AWAY      %s %s %s %s %s : %s -> %s (golden %s)' %
          (k[0], k[1], k[2], k[3], k[4], dict(A[k]), dict(B[k]), dict(G[k])))
