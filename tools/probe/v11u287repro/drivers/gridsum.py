#!/usr/bin/env python3
# v11u287 gridsum.py <grid file> [A] [B]: case-views moving between two binary tags (md5 or verdict), entering / leaving
# STRICT_EQUAL, exit-code and uhdm-cmp line-count changes. Reads only case.sh lines.
import sys,collections
rows=collections.defaultdict(dict)
for ln in open(sys.argv[1]):
    p=ln.split()
    if len(p)<3: continue
    k,t=p[0],p[1]; d=dict(x.split('=',1) for x in p[2:] if '=' in x); d['st']=p[2] if '=' not in p[2] else None; rows[k][t]=d
A=sys.argv[2] if len(sys.argv)>2 else 'P'; Bt=sys.argv[3] if len(sys.argv)>3 else 'F'
mv=ent=lv=rc=0
for k in sorted(rows):
    r=rows[k]
    if A not in r or Bt not in r: continue
    a,b=r[A],r[Bt]
    fl=[]
    if a.get('rc')!=b.get('rc'): fl.append('RC'); rc+=1
    if a.get('md5')==b.get('md5') and a.get('st')==b.get('st'): continue
    mv+=1
    ae='STRICT_EQUAL' in a.get('strict',''); be='STRICT_EQUAL' in b.get('strict','')
    if be and not ae: ent+=1; fl.append('ENTER')
    if ae and not be: lv+=1; fl.append('LEAVE')
    if a.get('cmplines')!=b.get('cmplines'): fl.append('CMPL')
    extra=' '.join(f"{t}:{r[t].get('md5')}" for t in ('P','L','O','F','V','FO') if t in r)
    print(f"{k:58s} {A}[{a.get('cmplines')} {a.get('strict')}] {Bt}[{b.get('cmplines')} {b.get('strict')}] {' '.join(fl)}")
print(f"{A}->{Bt}: views={len(rows)} moving={mv} entering={ent} leaving={lv} rcchg={rc}")
