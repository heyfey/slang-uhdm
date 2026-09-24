#!/usr/bin/env python3
"""unmask2.py <dir with g_P.rec P.rec P.diffs g_L.rec L.rec L.diffs>: difflib alignment (keys depth,type,name,defname) of
golden against P and against L inside a window around the new differences. For every field L differs on that P did not:
UNMASKED (P's aligned record holds the SAME off-golden value), WORSE (P's aligned record matched golden),
CHANGED (P aligned, a different off-golden value), NEWOBJ (golden's object has no counterpart in P's walk: the law
supplied it; printed with the field values so the face can be named)."""
import sys, difflib, collections
w=sys.argv[1]
N=['depth','type','name','defname','fullname','file','line','col','endline','endcol','decompile','size','value','consttype']
rd=lambda p:[l.split('\t') for l in open(p).read().split('\n')[:-1]]
G=rd(w+'/g_L.rec'); P=rd(w+'/P.rec'); L=rd(w+'/L.rec'); GP=rd(w+'/g_P.rec')
assert G==GP
dP={tuple(map(int,l.split())) for l in open(w+'/P.diffs')}; dL={tuple(map(int,l.split())) for l in open(w+'/L.diffs')}
key=lambda r: tuple(r[:4])
def div(X):
    for i in range(min(len(G),len(X))):
        if key(G[i])!=key(X[i]): return i
    return min(len(G),len(X))
dvP,dvL=div(P),div(L)
new=sorted(x for x in dL if x not in dP)
print(f'records G={len(G)} P={len(P)} L={len(L)}; walk divergence P #{dvP}, L #{dvL}; diff fields P {len(dP)}, L {len(dL)}; L-only {len(new)}')
if not new: sys.exit()
lo=max(0,min(i for i,_ in new)-3000); hi=min(len(G),max(i for i,_ in new)+3000)
def amap(X):
    off=len(X)-len(G); a=max(0,lo-abs(off)-3000); b=min(len(X),hi+abs(off)+3000)
    sm=difflib.SequenceMatcher(None,[key(r) for r in G[lo:hi]],[key(r) for r in X[a:b]],autojunk=False)
    m={}
    for x,y,n in sm.get_matching_blocks():
        for t in range(n): m[lo+x+t]=a+y+t
    return m
mP=amap(P)
cls=collections.Counter(); ex=collections.defaultdict(list)
for i,k in new:
    fv=lambda r: (r[k], r[14] if k==4 and len(r)>14 else '')
    if i>=dvL: c='PAST-L-DIVERGENCE(walk misaligned, not compared)'
    elif i<dvP: c='WORSE(before P divergence)'
    elif i in mP and fv(P[mP[i]])==fv(L[i]): c='UNMASKED'
    else:
        # content match: a P record in the window equal to golden's record on every field but k
        rest=lambda r: tuple(x for j,x in enumerate(r[:14]) if j!=k)
        cand=[r for r in P[max(0,i-6000):i+6000] if rest(r)==rest(G[i])]
        if any(fv(r)==fv(L[i]) for r in cand): c='UNMASKED(content)'
        elif k==4 and any(r[1]==L[i][1] and fv(r)==fv(L[i]) for r in P[max(0,i-6000):i+6000]): c='NEWOBJ(value present in P)'
        elif cand and all(fv(r)==fv(G[i]) for r in cand): c='WORSE'
        elif i in mP: c='CHANGED'
        else: c='NEWOBJ'
    cls[c]+=1
    if len(ex[c])<4: ex[c].append((i,N[k],'golden=%r'%(fv(G[i]),),'L=%r'%(fv(L[i]),),'P=%r'%(P[mP[i]][k] if i in mP else None),'|'.join(G[i][:4])))
print('classes:',dict(cls))
for c,v in ex.items():
    for e in v: print(' ',c,e)
