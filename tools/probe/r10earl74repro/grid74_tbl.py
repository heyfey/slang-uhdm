#!/usr/bin/env python3
"""r10earl74 — GOLDEN TABLE renderer for the dimension-bound grid.
One row per (owner chain, dim slot): golden payload vs ours, with a verdict.
usage: grid74_tbl.py <g.rg> <o.rg> [substring-filter]"""
import sys, collections, re
def load(p):
    d=collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('RG '): continue
        f=ln.rstrip('\n').split(' ',2)
        d[f[1]].append(f[2])
    for k in d:
        d[k]=sorted(set(d[k])) if len(set(d[k]))==1 else sorted(d[k])
    return d
def norm(v):
    v=re.sub(r'ct=\d+','ct=',v); return re.sub(r'val=[A-Z]+:','val=:',v)
G=load(sys.argv[1]); O=load(sys.argv[2])
filt=sys.argv[3] if len(sys.argv)>3 else ''
def short(k):
    p=[x for x in k.split('/') if not x.startswith('design(')]
    return '/'.join(p[-4:])
rows=[]
for k in sorted(set(list(G)+list(O))):
    if filt and filt not in k: continue
    g=G.get(k,[]); o=O.get(k,[])
    for i in range(max(len(g),len(o))):
        gv=g[i] if i<len(g) else '<absent>'; ov=o[i] if i<len(o) else '<absent>'
        if gv==ov: verdict='EQ'
        elif gv!='<absent>' and ov!='<absent>' and norm(gv)==norm(ov): verdict='CT'
        else: verdict='**'
        rows.append((verdict, short(k), gv, ov))
c=collections.Counter(r[0] for r in rows)
print('CELLS %d  %s'%(len(rows), dict(c)))
for v,k,gv,ov in rows:
    if v=='EQ': continue
    print('%s %s\n    G %s\n    O %s'%(v,k,gv,ov))
