#!/usr/bin/env python3
"""r10vrgg18repro/vscore18.py — 3-way score of one cell: GOLDEN vs BASE vs
PATCHED, per (slot-kind, key).  Prints TO-GOLDEN / AWAY-FROM-GOLDEN /
STILL-WRONG / UNCHANGED-RIGHT counts and lists every moved slot."""
import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for l in open(p):
        f = l.rstrip('\n').split('\t')
        if len(f) < 4: continue
        d[(f[1], f[2])].append('\t'.join(f[3:]))
    return {k: sorted(v) for k, v in d.items()}
G, B, P = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
keys = sorted(set(G) | set(B) | set(P))
cnt = collections.Counter()
for k in keys:
    g, b, p = G.get(k), B.get(k), P.get(k)
    if b == p:
        cnt['UNMOVED_RIGHT' if b == g else 'UNMOVED_WRONG'] += 1
        continue
    if b != g and p == g:
        cnt['TO_GOLDEN'] += 1; tag = 'TO_GOLDEN'
    elif b == g and p != g:
        cnt['AWAY_GOLDEN'] += 1; tag = '*** AWAY_GOLDEN ***'
    else:
        cnt['MOVED_STILL_WRONG'] += 1; tag = 'MOVED_STILL_WRONG'
    print('%-20s %s\n    G: %s\n    B: %s\n    P: %s' % (tag, k, g, b, p))
print('---- ' + sys.argv[4] if len(sys.argv) > 4 else '----')
for k in ('TO_GOLDEN', 'AWAY_GOLDEN', 'MOVED_STILL_WRONG', 'UNMOVED_RIGHT',
          'UNMOVED_WRONG'):
    print('%-18s %d' % (k, cnt[k]))
