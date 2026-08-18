#!/usr/bin/env python3
# r10earl69 — JUDGE-FAITHFUL 3-way score of a hier_path NAME census.
# `hier_path::Compare` reads Path_elems, then Root_value, then VpiName, so a
# cell whose ELEMENTS already differ from golden can never be judged on its
# name: it is scored STILL-WRONG(ELEMS-DIFFER) whatever the name does.
# MEASUREMENT ONLY.  usage: armscore69.py <g.hp> <pris-plain> <pat-plain> <pris-elab> <pat-elab>
import collections,sys
def load(p):
    d={}
    for l in open(p):
        f=l.rstrip().split(' ')
        if f[0]!='HP': continue
        kv={}
        for x in f[5:]:
            if '=' in x:
                k,v=x.split('=',1); kv.setdefault(k,v)
        d[(f[1],f[2],f[3],f[4])]=(f[-1], kv.get('name'))
    return d
g=load(sys.argv[1])
for view,pr,pa in (('plain',sys.argv[2],sys.argv[3]),('elab',sys.argv[4],sys.argv[5])):
    P=load(pr); Q=load(pa)
    b=collections.Counter(); rows=[]
    for k in sorted(set(g)|set(P)|set(Q)):
        gd=g.get(k); p=P.get(k); q=Q.get(k)
        def verdict(x):
            if x is None or gd is None: return 'ABSENT'
            if x[0]!=gd[0]: return 'ELEMS-DIFFER'
            return 'EQ' if x[1]==gd[1] else 'NAME-DIFFERS'
        vp, vq = verdict(p), verdict(q)
        if vp==vq: c='STILL-RIGHT' if vq=='EQ' else 'STILL-WRONG('+vq+')'
        elif vq=='EQ': c='TO-GOLDEN'
        elif vp=='EQ': c='AWAY-GOLDEN'
        else: c='MOVED-WRONG('+vp+'->'+vq+')'
        b[c]+=1
        if c.startswith('AWAY') or c.startswith('MOVED'): rows.append((c,k,gd[1] if gd else None,p[1] if p else None,q[1] if q else None))
    print(f'ARM {view:6} JUDGE-FAITHFUL cells {sum(b.values())}')
    for c,n in sorted(b.items()): print(f'    {c:36} {n}')
    for r in rows: print('      ',r[0],r[1][0],r[1][2],'| G',r[2],'| PRIS',r[3],'| PAT',r[4])
