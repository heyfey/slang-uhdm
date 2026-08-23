#!/usr/bin/env python3
# r10v105 scorer v2 — payload compared as a SET per key (multiplicity reported
# separately, because golden's ELAB copy COUNT is a pre-existing residue R-M).
import sys, collections
def load(p):
    d=collections.defaultdict(set); m=collections.Counter()
    for line in open(p):
        f=line.rstrip('\n').split('\t')
        if len(f)<12 or f[1]=='TP': continue
        view=f[0].split('.',1)[1]
        key=(view,f[2],f[3],f[4],f[5],f[6],f[7])
        d[key].add((f[8],f[9],f[10])); m[key]+=1
    return d,m
(g,gm),(a,am),(b,bm)=(load(x) for x in sys.argv[1:4])
filt=sys.argv[4] if len(sys.argv)>4 else ''
out=collections.Counter(); det=[]
for k in sorted(set(g)|set(a)|set(b)):
    if filt and filt not in '\t'.join(k): continue
    gp,ap,bp=g.get(k),a.get(k),b.get(k)
    if gp is None: out['EXTRA']+=1; det.append(('EXTRA',k,gp,ap,bp)); continue
    if ap is None and bp is None: out['MISS']+=1; det.append(('MISS',k,gp,ap,bp)); continue
    ga,ba=(ap==gp),(bp==gp)
    if ga and ba: out['AGREE_BOTH']+=1
    elif not ga and ba: out['TO-GOLDEN']+=1; det.append(('TO-GOLDEN',k,gp,ap,bp))
    elif ga and not ba: out['AWAY']+=1; det.append(('AWAY',k,gp,ap,bp))
    elif ap==bp: out['STILL']+=1; det.append(('STILL',k,gp,ap,bp))
    else: out['MOVED-WRONG']+=1; det.append(('MOVED-WRONG',k,gp,ap,bp))
    if am.get(k)!=bm.get(k): out['MULT-CHANGED']+=1; det.append(('MULT-CHANGED',k,gm.get(k),am.get(k),bm.get(k)))
for kk in ('AGREE_BOTH','TO-GOLDEN','AWAY','STILL','MOVED-WRONG','MULT-CHANGED','MISS','EXTRA'):
    print(f"{kk}\t{out[kk]}")
print('--- detail')
order={'AWAY':0,'MOVED-WRONG':1,'MULT-CHANGED':2,'TO-GOLDEN':3,'STILL':4,'MISS':5,'EXTRA':6}
for d in sorted(det,key=lambda x:order[x[0]]):
    print(d[0],'|',' '.join(d[1]),'| G=',d[2],'| PRIS=',d[3],'| PAT=',d[4])
