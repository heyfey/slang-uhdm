#!/usr/bin/env python3
# caseaway.py <gw> <tagP> <tagL> : per case-view, LOST/GAINED golden records (order-blind, depth dropped), from case.sh's record dumps
import sys, os, collections, glob
gw, tp, tl = sys.argv[1:4]
def ms(p):
    c = collections.Counter()
    if not os.path.exists(p): return None
    for l in open(p, errors='replace'):
        if '\t' in l: c[l.rstrip('\n').split('\t', 1)[1]] += 1
    return c
for d in sorted(glob.glob(gw + '/**/' + tp + '.a.rec', recursive=True)):
    d = os.path.dirname(d); rel = os.path.relpath(d, gw)
    G = ms(f'{d}/{tp}.a.rec'); P = ms(f'{d}/{tp}.b.rec'); L = ms(f'{d}/{tl}.b.rec')
    if L is None or P is None: continue
    shared = G & P; kept = G & L; lost = shared - kept; gained = kept - shared
    nl, ng = sum(lost.values()), sum(gained.values())
    if nl or ng or P != L:
        print(f'{rel} lost={nl} gained={ng} ours_changed={P != L}')
        for r, k in list(lost.items())[:6]: print('   LOST', k, repr(r[:180]))
