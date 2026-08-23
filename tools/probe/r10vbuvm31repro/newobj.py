# Keys the PATCHED binary has that NEITHER golden NOR pristine has (multiset counts).
import collections,sys,os
for W in sorted(sys.argv[1:]):
    rows=collections.defaultdict(lambda: collections.Counter())
    for v in ('def','elab'):
        for nm,side in (('g','G'),('pris','O'),('pat','P')):
            f='%s/cen.%s.%s.txt'%(W,nm,v)
            if not os.path.exists(f): continue
            for line in open(f):
                p=line.rstrip('\n').split('\t')
                if len(p)<10: continue
                rows[(v,p[2],p[3],p[4],p[5],p[6])][side]+=1
    new=[(k,d) for k,d in rows.items() if d['P']>d['O'] and d['P']>d['G']]
    gone=[(k,d) for k,d in rows.items() if d['P']<d['O']]
    print(os.path.basename(W),"PATCH-ONLY-OBJECTS:",len(new),"OBJECTS-LOST:",len(gone))
    for k,d in new: print("   NEW",k,dict(d))
    for k,d in gone: print("   LOST",k,dict(d))
