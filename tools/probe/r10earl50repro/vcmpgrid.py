#!/usr/bin/env python3
"""r10earl50 VERIFIER cell comparator: golden vs binaryA vs binaryB.

Reads three grid50.py outputs and prints, per CELL, only the cells whose
ANSWER MULTISET differs between A and B, labelled ONTO GOLDEN / AWAY (was on
golden) / both off golden.

WHY A MULTISET, and this is the trap that produced a 100-line false alarm
during this verification: a cell appears MORE THAN ONCE in a `--all` dump (the
DEF listing and the ELAB listing, and standalone-top listings besides), so a
`join` on the cell name yields the CARTESIAN PRODUCT of the three sides and
manufactures "AWAY FROM GOLDEN" rows that do not exist.  Compare the whole
per-cell multiset or do not compare at all.

  usage: vcmpgrid.py <golden.grid> <A.grid> <B.grid>
"""
import sys, collections
def load(p):
    c=collections.Counter()
    for l in open(p):
        f=l.split()
        if len(f)>=2: c[(f[0],f[1])]+=1
    return c
g,a,b = (load(p) for p in sys.argv[1:4])
cells = sorted({k[0] for k in list(g)+list(a)+list(b)})
nm=0
for c in cells:
    ga={k[1]:v for k,v in g.items() if k[0]==c}
    aa={k[1]:v for k,v in a.items() if k[0]==c}
    bb={k[1]:v for k,v in b.items() if k[0]==c}
    if aa==bb: continue
    nm+=1
    d = 'ONTO GOLDEN' if bb==ga else ('AWAY (was on golden)' if aa==ga else 'both off golden')
    print('   %-34s gold=%-22s pris=%-22s fix=%-22s  %s'%(c,ga,aa,bb,d))
print('   moved cells = %d'%nm)
