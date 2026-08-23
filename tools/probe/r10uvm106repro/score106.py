#!/usr/bin/env python3
"""score106.py <golden> <pris> <ship> <label>: per-CELL (key,payload) multiset
classification. TO_GOLDEN / AWAY_NEW_WRONG / AWAY_LOST_GOOD / STILL."""
import sys, collections, os
_here=os.path.dirname(os.path.abspath(__file__))
src=open(os.path.join(_here,'tab106.py')).read()
src=src[:src.rindex('\nmain()')]
ns={}
exec(compile(src,'tab','exec'),ns)
cells=ns['cells']; parse=ns['parse']
def bag(p):
    b=collections.defaultdict(collections.Counter)
    for (k,pay),c in cells(parse(p)).items(): b[k][pay]+=c
    return b
G,P,S=bag(sys.argv[1]),bag(sys.argv[2]),bag(sys.argv[3])
lab=sys.argv[4] if len(sys.argv)>4 else ''
keys=set(G)|set(P)|set(S)
tg=an=al=st=lat=0
det=[]
for k in sorted(keys):
    g,p,s=G[k],P[k],S[k]
    if p==s:
        if g!=s: st+=1
        continue
    pok=(p==g); sok=(s==g)
    if sok and not pok: tg+=1; det.append(('TO_GOLDEN',k,g,p,s))
    elif pok and not sok: al+=1; det.append(('AWAY_LOST_GOOD',k,g,p,s))
    elif not pok and not sok:
        # both wrong but changed: is it closer?  count as LATERAL unless it
        # introduced a payload golden does not have that pristine did not have
        lat+=1; det.append(('LATERAL',k,g,p,s))
print(f'SCORE {lab}: TO_GOLDEN={tg} AWAY_LOST_GOOD={al} LATERAL={lat} STILL_WRONG_UNCHANGED={st} keys={len(keys)}')
for t,k,g,p,s in det:
    print(f'  {t} {k}\n     G {dict(g)}\n     P {dict(p)}\n     S {dict(s)}')
