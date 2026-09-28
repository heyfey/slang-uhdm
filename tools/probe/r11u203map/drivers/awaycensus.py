#!/usr/bin/env python3
"""r11u203: the order-blind AWAY census of a law binary against the pristine one, per row-mode: strict records
(depth dropped, multiset) that golden and the PRISTINE database share and the LAW database lost (lost), and the
golden records the law database gained (gained). A lost record is a field the law moved away from golden.
Args: <pristine dumps root> <law dumps root> <jobs tsv of the law cross-section> -> stdout, one line per row-mode,
then the top lost record shapes (type + facet)."""
import sys, collections, os
P, L, J = sys.argv[1:4]
def ms(p):
    c = collections.Counter()
    for l in open(p, errors='replace'):
        if '\t' in l: c[l.rstrip('\n').split('\t', 1)[1]] += 1
    return c
tot = collections.Counter(); shapes = collections.Counter(); ex = {}
for l in open(J):
    c, m, n = l.split('\t')[:3]
    a = f'{P}/{c}/{m}/{n}.a'; b = f'{P}/{c}/{m}/{n}.b'; bl = f'{L}/{c}/{m}/{n}.b'
    if not (os.path.exists(a) and os.path.exists(b) and os.path.exists(bl)): print('MISSING', c, m, n); continue
    G, Pb, Lb = ms(a), ms(b), ms(bl)
    shared = G & Pb; kept = G & Lb
    lost = shared - kept; gained = kept - shared
    nl, ng = sum(lost.values()), sum(gained.values())
    print(f'{c}/{m}/{n} lost={nl} gained={ng} net={ng - nl}')
    for r, k in lost.items():
        f = r.split('\t'); shapes[(f[0], n)] += k
        ex.setdefault(f[0], (n, r[:160]))
    tot['lost'] += nl; tot['gained'] += ng
print('TOTAL', dict(tot))
for (t, n), k in shapes.most_common(40): print(f'  lost {k:5d} {t:22s} {n}   e.g. {ex[t][1]!r}')
