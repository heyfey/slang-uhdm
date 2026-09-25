import os,sys,collections,glob
D=sys.argv[1]
C=collections.Counter(); EX=collections.defaultdict(list); ROWS=collections.defaultdict(set)
for g in glob.glob(D+'/*.g'):
    o=g[:-2]+'.o'
    G=[l.rstrip('\n').split('\t') for l in open(g)]; O=[l.rstrip('\n').split('\t') for l in open(o)] if os.path.exists(o) else []
    if len(G)!=len(O): C[('COUNTMISMATCH',os.path.basename(g))]+=1; continue
    for a,b in zip(G,O):
        _,pt,role,nm,gf,gpf,ak,spn,ctx=a
        of,opf=b[4],b[5]
        def cls(f,pf):
            if f==pf+'.'+nm: return 'base'
            if f.endswith('.'+nm) or f.endswith('::'+nm): return 'scope'
            return 'other'
        k=(pt,role,cls(gf,gpf),cls(of,opf),gf==of)
        C[k]+=1; ROWS[k].add(os.path.basename(g)[:-2])
        if len(EX[k])<3: EX[k].append((os.path.basename(g),nm,gf,of,ctx[:100]))
for k,v in sorted(C.items(),key=lambda x:-x[1]):
    print(v,k,'rows=%d'%len(ROWS[k]))
    for e in EX[k]: print('     ',e)
