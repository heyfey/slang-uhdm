# Report cells where GOLDEN has NO vpiExpr but PATCHED emits one (invention),
# and cells where GOLDEN has one, PRISTINE matched, and PATCHED differs.
import collections,sys,glob,os
for W in sorted(sys.argv[1:]):
    rows=collections.defaultdict(lambda: collections.defaultdict(list))
    for v in ('def','elab'):
        for nm,side in (('g','G'),('pris','O'),('pat','P')):
            f='%s/cen.%s.%s.txt'%(W,nm,v)
            if not os.path.exists(f): continue
            for line in open(f):
                p=line.rstrip('\n').split('\t')
                if len(p)<10: continue
                rows[(v,p[2],p[3],p[4],p[5],p[6])][side].append(p[7])
    inv=[];extra=[]
    for k,d in rows.items():
        g=sorted(d.get('G',[]));o=sorted(d.get('O',[]));p=sorted(d.get('P',[]))
        if not g and p: extra.append((k,p)); continue
        gn=[x for x in g if x!='expr=-']; pn=[x for x in p if x!='expr=-']
        if not gn and pn: inv.append((k,g,o,p))
    print(os.path.basename(W),"INVENTED-EXPR(golden has none):",len(inv),"EXTRA-OBJECT(golden has no such var):",len(extra))
    for x in inv[:10]: print("   INV",x)
    for x in extra[:10]: print("   EXT",x)
