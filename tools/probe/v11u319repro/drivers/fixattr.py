#!/usr/bin/env python3
# v11u319 fixattr.py <dir>: every case-view where the fix differs from the law, with the one verifier switch that gives the
# law's bytes back (a_<switch>.txt from agrid.sh with that switch set).
import os, sys
from collections import Counter
os.chdir(sys.argv[1])
def rd(f):
    d={}
    for l in open(f):
        p=l.split(); d[p[0]]=dict(x.split('=',1) for x in p[2:] if '=' in x)
    return d
P,L,F=rd('aP.txt'),rd('aL.txt'),rd('aF.txt')
sws=['R11V319_INNERVSLEAF_OFF','R11V319_MODASSOC_OFF','R11V319_MODPAREN_OFF']
S={s:rd('a_%s.txt'%s) for s in sws}
c=Counter(); n=0
for k in sorted(P):
    if F[k]['md5']==L[k]['md5']: continue
    n+=1
    r=[s[8:-4] for s in sws if S[s][k]['md5']==L[k]['md5']]
    c[','.join(r) or 'none']+=1
    print(k.replace('tp/v11u319repro/cases/',''),'P=%s(%s)'%(P[k]['strict'],P[k]['cmplines']),'L=%s(%s)'%(L[k]['strict'],L[k]['cmplines']),
          'F=%s(%s)'%(F[k]['strict'],F[k]['cmplines']),'restore='+(','.join(r) or '-'))
print('# fix differs from law on',n,'case-views; restored by one switch:',dict(c))
