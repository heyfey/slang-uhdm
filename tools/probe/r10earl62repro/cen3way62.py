#!/usr/bin/env python3
"""r10earl62 — the 3-way golden / pristine / patched MULTISET JOIN used for
every census number in README.md.  TO-GOLDEN = pristine wrong -> patched equals
golden;  AWAY-GOLDEN = pristine right -> patched wrong (fatal);  STILL-WRONG =
both wrong, differently.  MEASUREMENT ONLY.

  usage: cen3way62.py <golden.cen> <pristine.cen> <patched.cen> [limit]
"""
import sys,collections
g,pr,pa=sys.argv[1],sys.argv[2],sys.argv[3]
def load(p):
    c=collections.Counter()
    for l in open(p,errors='replace'): c[l.rstrip()]+=1
    return c
G,P,Q=load(g),load(pr),load(pa)
to=away=still=0; rows=[]
for k in set(G)|set(P)|set(Q):
    a,b,c=G[k],P[k],Q[k]
    if b==c: continue
    if b!=a and c==a: to+=1; rows.append(('TO-GOLDEN',k,a,b,c))
    elif b==a and c!=a: away+=1; rows.append(('AWAY-GOLDEN',k,a,b,c))
    else: still+=1; rows.append(('STILL-WRONG',k,a,b,c))
print('TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d'%(to,away,still))
for r in sorted(rows,key=lambda r:(r[0]!='AWAY-GOLDEN',r[0]))[:int(sys.argv[4]) if len(sys.argv)>4 else 25]:
    print('  %-12s g=%d p=%d q=%d  %s'%(r[0],r[2],r[3],r[4],r[1][:130]))
