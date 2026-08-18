#!/usr/bin/env python3
"""vbuvm19 verifier — view-GENERAL three-way foreach census table.
usage: vcmp19.py <gold.json> <pris.json> <pat.json>"""
import json,sys,os
def load(p):
    if not p or not os.path.exists(p): return None
    x={}
    for v,fn,loc,kind,nm,ts,act in json.load(open(p)):
        x.setdefault((fn,loc),{})[v]=(kind,nm,ts,act)
    return x
G=load(sys.argv[1]); O=load(sys.argv[2]); P=load(sys.argv[3]) if len(sys.argv)>3 else None
views=set()
for d in (G,O,P):
    if d:
        for k,vv in d.items(): views|=set(vv)
ks=sorted(set(G)|set(O))
n=same=conv=over=res=msw=0
for k in ks:
    for view in sorted(views):
        gv=G.get(k,{}).get(view); ov=O.get(k,{}).get(view)
        pv=P.get(k,{}).get(view) if P else None
        if not (gv or ov): continue
        n+=1
        if P is None: verdict='same' if gv==ov else 'DIFF'
        elif gv==ov==pv: verdict='same'; same+=1
        elif gv!=ov and gv==pv: verdict='CONVERTED'; conv+=1
        elif gv==ov and gv!=pv: verdict='OVER-FIRE'; over+=1
        elif gv!=ov and ov==pv: verdict='residue'; res+=1
        else: verdict='MOVED-STILL-WRONG'; msw+=1
        if verdict!='same':
            print('%-18s %-42s %-12s %-18s G=%-40s O=%-40s P=%s'%(verdict,k[0],k[1],view[4:],str(gv),str(ov),str(pv)))
print('-- CELLS %d  same %d  CONVERTED %d  OVER-FIRE %d  MOVED-STILL-WRONG %d  residue %d'%(n,same,conv,over,msw,res))
