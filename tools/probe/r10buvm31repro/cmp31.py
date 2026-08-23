# r10buvm31repro/cmp31.py — the three-way arm scorer.  MEASUREMENT ONLY.
#
#   cmp31.py <grid31.sh workdir>
#
# Joins cen.g.txt (GOLDEN, always LHS), cen.o.txt (PRISTINE) and cen.p.txt
# (PATCHED) on (loc, var kind, vpiArrayType, name) as a MULTISET (a
# last-writer dict drops rows — buvm22's trap) and buckets every cell:
#   FIXED                    golden != pristine, golden == patched
#   MOVED-WRONG              golden == pristine, golden != patched   (must be 0)
#   MOVED-BUT-STILL-UNEQUAL  changed and still not golden            (must be 0)
#   UNCHANGED-UNEQUAL        the law did not reach it
# Only the JUDGE-VISIBLE payload (the expr shape) is compared; the vpiParent
# column travels beside it and never enters the verdict.
import collections,sys
W=sys.argv[1]
def load(f):
    d=collections.defaultdict(list)
    for line in open(f):
        p=line.rstrip('\n').split('\t')
        if len(p)<10: continue
        d[(p[2],p[3],p[4],p[5])].append((p[7],p[8]))
    return d
G=load(W+'/cen.g.txt'); O=load(W+'/cen.o.txt'); P=load(W+'/cen.p.txt')
eqO=eqP=0; fixed=[]; broke=[]; still=[]; moved=[]
for k in sorted(set(G)|set(O)|set(P), key=lambda k:(int(k[0].split(':')[0]) if k[0]!='-' else 0,k[1])):
    g=sorted(G.get(k,[])); o=sorted(O.get(k,[])); p=sorted(P.get(k,[]))
    gj=[x[0] for x in g]; oj=[x[0] for x in o]; pj=[x[0] for x in p]   # judge payload only (expr shape)
    if gj==oj and gj==pj: eqO+=1; eqP+=1; continue
    if gj!=oj and gj==pj: fixed.append((k,gj,oj)); continue
    if gj==oj and gj!=pj: broke.append((k,gj,oj,pj)); continue
    if gj!=oj and gj!=pj:
        if oj==pj: still.append((k,gj,oj))
        else: moved.append((k,gj,oj,pj))
print("FIXED(unequal->equal):",len(fixed))
for x in fixed: print("   ",x[0],"G:",x[1],"O:",x[2])
print("MOVED-WRONG(equal->unequal):",len(broke))
for x in broke: print("   ",x)
print("MOVED-BUT-STILL-UNEQUAL:",len(moved))
for x in moved: print("   ",x[0],"\n      G:",x[1],"\n      O:",x[2],"\n      P:",x[3])
print("UNCHANGED-UNEQUAL:",len(still))
for x in still: print("   ",x[0],"G:",x[1],"O:",x[2])
