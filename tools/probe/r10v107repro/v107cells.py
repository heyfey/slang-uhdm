#!/usr/bin/env python3
# r10v107 — print every census cell where golden, pristine or patched disagree.
# MEASUREMENT ONLY.  LHS is ALWAYS golden.
import sys, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) > 10 and f[1] == 'REF':
            d[(f[2], f[3], f[4], f[5], f[6])][f[7]] += 1
    return d
G,A,B = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
lab = sys.argv[4]
for k in sorted(set(G)|set(A)|set(B)):
    g,a,b = dict(G.get(k,{})), dict(A.get(k,{})), dict(B.get(k,{}))
    if g==a==b: continue
    verd = 'SAME'
    if b==g and a!=g: verd='TO-GOLDEN'
    elif a==g and b!=g: verd='AWAY'
    elif a!=g and b!=g and a!=b: verd='STILL'
    elif a!=g and b!=g and a==b: verd='UNMOVED-WRONG'
    print('%-14s %-8s %s %s %s %s %s | G=%s PRIS=%s PAT=%s' % (lab,verd,k[0],k[1],k[2],k[3],k[4],g,a,b))
