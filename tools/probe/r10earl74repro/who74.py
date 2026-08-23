#!/usr/bin/env python3
# r10earl74 — print the OWNER CHAIN of every (ct,tag)-only range disagreement.
# usage: who74.py <golden.rg> <ours.rg>   MEASUREMENT ONLY.
import sys, collections, re
def load(p):
    d=collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('RG '): continue
        f=ln.rstrip('\n').split(' ',2)
        d[f[1]].append(f[2])
    for k in d: d[k].sort()
    return d
G,O=load(sys.argv[1]),load(sys.argv[2])
for k in sorted(G):
    if k not in O: continue
    g,o=G[k],O[k]
    for i in range(min(len(g),len(o))):
        if g[i]!=o[i]:
            gg=re.sub(r'ct=\d+','ct=',g[i]); oo=re.sub(r'ct=\d+','ct=',o[i])
            gg=re.sub(r'val=[A-Z]+:','val=:',gg); oo=re.sub(r'val=[A-Z]+:','val=:',oo)
            if gg!=oo: continue
            print('KEY',k)
            print('  G:',g[i]); print('  O:',o[i])
