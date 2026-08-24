#!/usr/bin/env python3
# r10vbuvm34repro/vscore34.py — VIEW-GENERAL MULTISET scorer: golden vs
# pristine vs patched, per arm-view.  Verdicts per KEY (loc, slot, name) over
# the payload MULTISET: SAME / FIXED / RESIDUE / BROKEN (pristine-right,
# patched-wrong — the number that must be ZERO).  Also an order-blind MULTISET
# DISTANCE to golden for each side.  MEASUREMENT ONLY.
import collections, sys, vdump34

def load(p, fam):
    d = collections.defaultdict(collections.Counter)
    for r in vdump34.rows(p, ''):
        if r[0] != fam: continue
        d[(r[1], r[2], r[3])][tuple(r[4:])] += 1
    return d

def dist(a, b):
    keys = set(a) | set(b)
    n = 0
    for k in keys:
        ca, cb = a.get(k, collections.Counter()), b.get(k, collections.Counter())
        n += sum(((ca - cb) + (cb - ca)).values())
    return n

fam = sys.argv[4] if len(sys.argv) > 4 else 'FELV'
G, P, O = load(sys.argv[1], fam), load(sys.argv[2], fam), load(sys.argv[3], fam)
tot = collections.Counter(); lines = []
for k in sorted(set(G) | set(P) | set(O), key=lambda k: (int(k[0].split(':')[0]) if k[0] else 0, k[1], k[2])):
    g, p, o = G.get(k, collections.Counter()), P.get(k, collections.Counter()), O.get(k, collections.Counter())
    if g == p and g == o:   v = 'SAME'
    elif g != p and g == o: v = 'FIXED'
    elif g == p and g != o: v = 'BROKEN'
    else:                   v = 'RESIDUE'
    tot[v] += 1
    if v != 'SAME':
        lines.append(f"{v:8s} @{k[0]:10s} slot{k[1]} {k[2]:6s}  G={dict(g)}  PRIS={dict(p)}  PAT={dict(o)}")
if '-q' not in sys.argv:
    print('\n'.join(lines))
print(f"{fam}: SAME={tot['SAME']} FIXED={tot['FIXED']} RESIDUE={tot['RESIDUE']} BROKEN={tot['BROKEN']}  "
      f"dist(G,PRIS)={dist(G,P)} dist(G,PAT)={dist(G,O)}")
