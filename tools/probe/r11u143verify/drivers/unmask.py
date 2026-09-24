#!/usr/bin/env python3
"""unmask.py <dir with g_P.rec P.rec P.diffs g_L.rec L.rec L.diffs> : every field L differs from golden that P did not
report: before P's walk divergence -> WORSE; past it -> compare with P's record for the same golden object (aligned by
a local key search): UNMASKED if P holds the same off-golden value, WORSE if P matched golden."""
import sys
w=sys.argv[1]
N=['depth','type','name','defname','fullname','file','line','col','endline','endcol','decompile','size','value','consttype']
rd=lambda p:[l.split('\t') for l in open(p).read().split('\n')[:-1]]
G=rd(w+'/g_P.rec'); GL=rd(w+'/g_L.rec'); P=rd(w+'/P.rec'); L=rd(w+'/L.rec')
assert G==GL
dP={tuple(map(int,l.split())) for l in open(w+'/P.diffs')}; dL={tuple(map(int,l.split())) for l in open(w+'/L.diffs')}
key=lambda r: tuple(r[:4])
def div(X):
    for i in range(min(len(G),len(X))):
        if key(G[i])[:2]!=key(X[i])[:2]: return i
    return min(len(G),len(X))
dvP,dvL=div(P),div(L)
print(f'records G={len(G)} P={len(P)} L={len(L)}; P walk diverges at #{dvP}, L at #{dvL}; P diff fields {len(dP)}, L diff fields {len(dL)}')
new=sorted(x for x in dL if x not in dP)
worse=[];unm=[];other=[]
def findP(i):
    for off in sorted(range(-60,61),key=abs):
        j=i+off
        if 0<=j<len(P) and all(0<=j+t<len(P) and 0<=i+t<len(G) and key(P[j+t])==key(G[i+t]) for t in range(-3,4)): return j
    return None
for i,k in new:
    if i<dvP: worse.append((i,N[k],G[i][k],L[i][k])); continue
    j=findP(i)
    if j is None: other.append((i,N[k],'no P alignment')); continue
    if P[j][k]==L[i][k] and P[j][k]!=G[i][k]: unm.append((i,j,N[k]))
    elif P[j][k]==G[i][k]: worse.append((i,N[k],G[i][k],L[i][k],'P#%d matched'%j))
    else: other.append((i,N[k],G[i][k],P[j][k],L[i][k]))
nb=sum(1 for x in worse if len(x)==4); na=sum(1 for x in worse if len(x)==5)
print(f'fields L differs on that P did not report: {len(new)} = WORSE before P divergence {nb} + UNMASKED {len(unm)} + WORSE past divergence {na} + OTHER {len(other)}')
for x in worse[:5]: print('  WORSE',x)
for x in other[:5]: print('  OTHER',x)
for x in unm[:3]: print('  UNMASKED e.g. golden #%d = P #%d, field %s' % x)
