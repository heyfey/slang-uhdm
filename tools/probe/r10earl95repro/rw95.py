#!/usr/bin/env python3
"""r10earl95 -- print the RIGHT->WRONG and no-golden-key cells verd95corpus.py
counts.  MEASUREMENT ONLY.  usage: rw95.py <g.cen> <pristine.cen> <patched.cen>"""
import sys, collections
def load(p):
    d=collections.defaultdict(collections.Counter)
    for ln in open(p):
        ln=ln.rstrip('\n')
        if not ln: continue
        tag,_,rest=ln.partition('\t'); k,_,r2=rest.partition(' => '); pay,_,n=r2.rpartition(' #')
        d[(tag,k)][pay]+=int(n)
    return d
G,O,Q=(load(a) for a in sys.argv[1:4])
for key in sorted(set(O)|set(Q)):
    if key[1].startswith('GA|'): continue
    gp=G.get(key); op=O.get(key,collections.Counter()); qp=Q.get(key,collections.Counter())
    if op==qp: continue
    if gp is None:
        print("NOGOLDENKEY",key[1],"\n   O",dict(op),"\n   Q",dict(qp)); continue
    ro=sum(min(c,gp.get(p,0)) for p,c in op.items()); rq=sum(min(c,gp.get(p,0)) for p,c in qp.items())
    if rq<ro:
        print("RIGHT->WRONG",key[1],"\n   G",dict(gp),"\n   O",dict(op),"\n   Q",dict(qp))
