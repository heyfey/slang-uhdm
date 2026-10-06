#!/usr/bin/env python3
import sys, collections
# v11u262 trisum.py <tri output> [all]: per case-view P / L / F verdicts, whether F equals L or P, whether R11V262_OFF gives the law bytes; totals.
rows=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f=l.split()
    if len(f)<3: continue
    d=dict(x.split('=',1) for x in f[2:] if '=' in x); d['raw']=' '.join(f[2:])
    rows[f[0]][f[1]]=d
tot=collections.Counter()
for cv in sorted(rows):
    r=rows[cv]; P,L,F,FV=(r.get(k,{}) for k in ('P','L','F','FV'))
    s=lambda x:x.get('strict',x.get('raw','?'))
    fl = 'F=L' if F.get('md5')==L.get('md5') else ('F=P' if F.get('md5')==P.get('md5') else 'F=own')
    fv = 'FVOFF=L' if FV.get('md5')==L.get('md5') else 'FVOFF!=L'
    tot[fl]+=1; tot[fv]+=1
    if s(P).startswith('STRICT_EQUAL') and not s(F).startswith('STRICT_EQUAL'): tot['F leaves SE vs P']+=1
    if s(F).startswith('STRICT_EQUAL') and not s(P).startswith('STRICT_EQUAL'): tot['F enters SE vs P']+=1
    if s(L).startswith('STRICT_EQUAL') and not s(F).startswith('STRICT_EQUAL'): tot['F leaves SE vs L']+=1
    rc=set(x.get('rc') for x in (P,L,F,FV))
    if rc!={'0'}: tot['rc!=0']+=1
    if fl!='F=L' or len(sys.argv)>2: print(f"{cv:28s} P={s(P):28s} L={s(L):28s} F={s(F):28s} {fl} {fv} rc={'/'.join(x.get('rc','?') for x in (P,L,F))}")
print(dict(tot))
