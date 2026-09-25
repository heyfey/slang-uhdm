import os,sys,collections,glob
D=sys.argv[1]; only=sys.argv[2] if len(sys.argv)>2 else None
C=collections.Counter(); EX=collections.defaultdict(list); ROWS=collections.defaultdict(set)
for g in glob.glob(D+'/*.g'):
    o=g[:-2]+'.o'
    G=[l.rstrip('\n').split('\t') for l in open(g)]; O=[l.rstrip('\n').split('\t') for l in open(o)] if os.path.exists(o) else []
    if len(G)!=len(O): C[('COUNTMISMATCH',)]+=1; continue
    for a,b in zip(G,O):
        _,gf,ppt,role,ppf,mif,spn,ctx=a
        of=b[1]
        if only and ppt!=only: continue
        def cls(f):
            if f==mif: return 'inst'
            if f==ppf: return 'selfull'
            if f.startswith(mif+'.'): return 'inst+'
            return 'other'
        gs=ctx.split('<')
        ing='gen' if 'gen_scope' in ctx else '-'
        k=(ppt,role,cls(gf),cls(of),gf==of,ing)
        C[k]+=1; ROWS[k].add(os.path.basename(g)[:-2])
        if len(EX[k])<3: EX[k].append((os.path.basename(g)[:-2],gf,of,ppf,ctx[:110]))
for k,v in sorted(C.items(),key=lambda x:-x[1]):
    print(v,k,'rows=%d'%len(ROWS[k]))
    for e in EX[k]: print('     ',e)
