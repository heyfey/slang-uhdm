#!/usr/bin/env python3
# r10uvm110 -- multiset join of two cen110 censuses.  LHS is ALWAYS golden.
# Prints per-key AGREE / DIFFER / LHS-ONLY / RHS-ONLY and the differing rows.
import sys, collections
def load(p):
    d=collections.defaultdict(list)
    for ln in open(p):
        a=ln.rstrip('\n').split('\t')
        if len(a)!=3: continue
        d[(a[0],a[1])].append(a[2])
    return d
L=load(sys.argv[1]); R=load(sys.argv[2])
tag=sys.argv[3] if len(sys.argv)>3 else ''
agree=differ=lonly=ronly=0
diffs=[]
for k in sorted(set(L)|set(R)):
    lv=sorted(L.get(k,[])); rv=sorted(R.get(k,[]))
    if not rv: lonly+=len(lv); diffs.append(('LHS-ONLY',k,lv,rv)); continue
    if not lv: ronly+=len(rv); diffs.append(('RHS-ONLY',k,lv,rv)); continue
    la=collections.Counter(lv); ra=collections.Counter(rv)
    common=sum((la&ra).values())
    agree+=common
    d=sum((la-ra).values())+sum((ra-la).values())
    if d:
        differ+=1
        diffs.append(('DIFFER',k,sorted((la-ra).elements()),sorted((ra-la).elements())))
print('%s AGREE=%d DIFFERKEYS=%d LHSONLY=%d RHSONLY=%d'%(tag,agree,differ,lonly,ronly))
for t,k,lv,rv in diffs:
    print('  %s %s %s'%(t,k[0],k[1]))
    for v in lv: print('    L %s'%v)
    for v in rv: print('    R %s'%v)
