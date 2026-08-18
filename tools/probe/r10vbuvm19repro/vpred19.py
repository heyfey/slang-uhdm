#!/usr/bin/env python3
"""Independent mover prediction + three-way owner-keyed contingency."""
import sys,re,collections
def load(p):
    d={}
    for line in open(p):
        if not line.startswith('FA '): continue
        f=line.split()
        side_db=f[1]; side,db=side_db.split(':',1)
        rec={}
        for tok in f[2:]:
            k,_,v=tok.partition('=')
            rec.setdefault(k,v)
        key=(db,rec.get('key'),rec.get('view'))
        d.setdefault(side,{}).setdefault(key,[]).append((rec.get('vk'),rec.get('vn'),rec.get('ts'),rec.get('act'),rec.get('lv')))
    return d
P=load(sys.argv[1])   # pristine census (G + O)
Q=load(sys.argv[2]) if len(sys.argv)>2 else None  # patched census (G + O)
G,O=P['G'],P['O']
# 1. prediction: ELABPKG cell, golden ts NONE, ours ts TS
pred=collections.Counter(); cells=0
for k,gv in G.items():
    if k[2]!='ELABPKG': continue
    ov=O.get(k)
    if not ov: continue
    for a,b in zip(sorted(gv),sorted(ov)):
        if a[2]=='NONE' and b[2]=='TS':
            pred[k[0]]+=1; cells+=1
print('PREDICTED-MOVER-DBS %d  CELLS %d'%(len(pred),cells))
for db,c in sorted(pred.items()): print('   %-60s %d'%(db,c))
# 2. contingency ELABPKG (golden ts, ours ts) pristine vs patched
def cont(d):
    c=collections.Counter()
    for k,gv in d['G'].items():
        if k[2]!='ELABPKG': continue
        ov=d['O'].get(k)
        if not ov: c[('MISSING','-')]+=len(gv); continue
        for a,b in zip(sorted(gv),sorted(ov)): c[(a[2],b[2])]+=1
    return c
cp=cont(P); print('\nELABPKG contingency PRISTINE:',dict(cp))
if Q:
    cq=cont(Q); print('ELABPKG contingency PATCHED :',dict(cq))
# 3. per-slot TO-GOLDEN / AWAY / STILL over ALL views
if Q:
    tg=aw=st=0; away=[]
    for k,gv in P['G'].items():
        ov=P['O'].get(k); nv=Q['O'].get(k)
        if ov is None or nv is None: continue
        for a,b,c in zip(sorted(gv),sorted(ov),sorted(nv)):
            if b==c: continue
            if c==a: tg+=1
            elif b==a: aw+=1; away.append((k,a,b,c))
            else: st+=1; away.append(('STILL',k,a,b,c))
    print('\nSLOT MOVES over ALL views: TO-GOLDEN %d  AWAY %d  MOVED-STILL-WRONG %d'%(tg,aw,st))
    for r in away[:40]: print('   ',r)
# 4. loop-var invariance
if Q:
    bad=0
    for k,ov in P['O'].items():
        nv=Q['O'].get(k)
        if nv is None: continue
        if sorted(x[4] for x in ov)!=sorted(x[4] for x in nv): bad+=1
    print('LOOPVAR listings changed by the patch: %d'%bad)
