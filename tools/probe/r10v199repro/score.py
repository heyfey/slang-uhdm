import sys, collections, glob, os
def load(p):
    d=collections.defaultdict(collections.Counter)
    for ln in open(p):
        ln=ln.rstrip('\n')
        if not ln or '\t' not in ln: continue
        k,rest=ln.split('\t',1)
        parts=k.split('|')
        if len(parts)<6: continue
        view,ok,on,listing,idx,pname=parts[0],parts[1],parts[2],parts[3],parts[4],parts[5]
        key=(view,ok,on,listing,pname)
        d[key][rest]+=1
    return d
def score(g,o,filt):
    ag=tg=to=og=oo=0; details=[]
    keys=set(k for k in g if filt(k))|set(k for k in o if filt(k))
    for k in sorted(keys):
        cg=g.get(k,collections.Counter()); co=o.get(k,collections.Counter())
        if not cg:
            oo+=sum(co.values()); details.append(('ONLY-OURS',k,dict(co))); continue
        if not co:
            og+=sum(cg.values()); details.append(('ONLY-GOLDEN',k,dict(cg))); continue
        a=sum(min(cg[v],co[v]) for v in set(cg)|set(co))
        ag+=a; dg=sum(cg.values())-a; do=sum(co.values())-a
        tg+=dg; to+=do
        if dg or do: details.append(('DIFF',k,{'G':dict(cg),'O':dict(co)}))
    return ag,tg,to,og,oo,details
gp,op,tag=sys.argv[1],sys.argv[2],sys.argv[3]
views=sys.argv[4].split(',') if len(sys.argv)>4 else None
g=load(gp); o=load(op)
gviews=set(k[0] for k in g)
filt_ts=lambda k:(k[3] in ('Parameters','PA.Lhs')) and k[0] in gviews
filt_rhs=lambda k:(k[3]=='PA.Rhs') and k[0] in gviews
a,tgd,tod,og,oo,det=score(g,o,filt_ts)
print(f"{tag} TS AGREE={a} DIFF-G={tgd} DIFF-O={tod} ONLY-G={og} ONLY-O={oo}")
for t,k,v in det: print(f"   {t} {'|'.join(k)} {v}")
a2,t2,t3,og2,oo2,det2=score(g,o,filt_rhs)
print(f"{tag} RHS AGREE={a2} DIFF-G={t2} DIFF-O={t3} ONLY-G={og2} ONLY-O={oo2}")
