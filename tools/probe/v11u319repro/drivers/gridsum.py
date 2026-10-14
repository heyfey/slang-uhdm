#!/usr/bin/env python3
# v11u319 gridsum.py <dir>: reads aP.txt aL.txt aF.txt aFOFF.txt aOFF.txt (agrid.sh outputs) in <dir>; prints the law and
# fix mover counts against pristine, OFF==P and FOFF==L checks, and every case-view where the fix differs from the law.
import os, sys
os.chdir(sys.argv[1])
def rd(f):
    d={}
    for l in open(f):
        p=l.split(); d[p[0]]=dict(x.split('=',1) for x in p[2:] if '=' in x)
    return d
P,L,F,FO,O=[rd(x) for x in ('aP.txt','aL.txt','aF.txt','aFOFF.txt','aOFF.txt')]
eq=lambda r: r.get('cmp')=='0' and r.get('strict','').startswith('STRICT_EQUAL')
print('case-views',len(P),'OFF!=P', sum(O[k].get('md5')!=P[k].get('md5') for k in P), 'FOFF!=L', sum(FO[k].get('md5')!=L[k].get('md5') for k in P),
      'nonzero rc', sum(X[k].get('rc')!='0' for k in P for X in (P,L,F,FO,O)))
for name,X in (('LAW',L),('FIX',F)):
    mv=[k for k in P if X[k].get('md5')!=P[k].get('md5')]
    print(name,'moving',len(mv),'entering',sum(eq(X[k]) and not eq(P[k]) for k in mv),'leaving',sum(eq(P[k]) and not eq(X[k]) for k in mv))
