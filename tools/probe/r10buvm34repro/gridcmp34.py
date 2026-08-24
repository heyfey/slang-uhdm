#!/usr/bin/env python3
# r10buvm34repro/gridcmp34.py — VIEW-GENERAL MULTISET comparator for foreach
# LOOP VARIABLES.  Reads r10buvm34cen rows for one arm and votes, per
# (view, foreach span, slot, loop-var name), SAME / FIXED / RESIDUE / BROKEN.
# Never keys on the dump's parenthesised fullname (vgrid33's trap) and never
# keeps a first/last writer per source line (buvm19/22's trap): every
# occurrence is a MULTISET row.  MEASUREMENT ONLY.
import collections, sys
def load(p, want):
    d = collections.defaultdict(collections.Counter)
    for l in open(p):
        f = l.rstrip('\n').split('\t')
        if len(f) < 9 or f[1] != 'FELV': continue
        side, view = f[0].split('|')
        if side != want: continue
        d[(view, f[3], f[4], f[5])][(f[6], f[8])] += 1
    return d
G = load(sys.argv[1], 'G')
P = load(sys.argv[2] if len(sys.argv) > 2 else sys.argv[1], 'P')
O = load(sys.argv[3] if len(sys.argv) > 3 else sys.argv[1], 'O')
keys = sorted(set(G) | set(P) | set(O), key=lambda k: (k[0], int(k[1].split(':')[0]), k[2]))
tot = collections.Counter()
for k in keys:
    g, p, o = G.get(k, collections.Counter()), P.get(k, collections.Counter()), O.get(k, collections.Counter())
    if g == p and g == o:   v = 'SAME'
    elif g != p and g == o: v = 'FIXED'
    elif g == p and g != o: v = 'BROKEN'
    else:                   v = 'RESIDUE'
    tot[(k[0], v)] += 1
    if v != 'SAME' and '-q' not in sys.argv:
        print(f"{v:8s} {k[0]:4s} {k[1]:14s} slot{k[2]} {k[3]:8s} G:{dict(g)} PRIS:{dict(p)} PATCH:{dict(o)}")
for view in sorted(set(k[0] for k in keys)):
    print(f"VIEW {view}: " + " ".join(f"{v}={tot[(view,v)]}" for v in ('SAME','FIXED','RESIDUE','BROKEN')))
