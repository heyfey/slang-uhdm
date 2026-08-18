import sys, os, glob, collections
def load(p):
    d=collections.defaultdict(collections.Counter)
    if not os.path.exists(p): return d
    for l in open(p, errors='replace'):
        c=l.rstrip('\n').split('\t')
        if len(c)<9: continue
        d[(c[0],c[7])][(c[1],c[4])]+=1
    return d,None
fam=collections.Counter(); ex={}
for g in sorted(glob.glob(sys.argv[1]+'/*.g')):
    base=g[:-2]
    G,_=load(g); P,_=load(base+'.p'); R,_=load(base+'.r')
    for k in set(G)|set(P)|set(R):
        a,p=G[k],P[k]
        if a==p: continue
        ka=tuple(sorted(set(x[0] for x in a))); kp=tuple(sorted(set(x[0] for x in p)))
        na=sum(a.values()); npp=sum(p.values())
        tag=('KIND %s->%s'%(kp,ka)) if ka!=kp else ('MULTIPLICITY g=%d ours=%d'%(na,npp))
        fam[tag]+=1; ex.setdefault(tag,(os.path.basename(base),k))
for t,n in fam.most_common(15): print('%6d  %-46s  eg %s'%(n,t,ex[t]))
