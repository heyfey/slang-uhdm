import sys, collections
def load(p, filt):
    d=collections.Counter()
    for ln in open(p):
        ln=ln.rstrip('\n')
        if '\t||\t' not in ln: continue
        k,v=ln.split('\t||\t',1)
        k=k.split('\t',1)[1]
        if filt and filt not in k: continue
        d[(k,v)]+=1
    return d
filt=sys.argv[3] if len(sys.argv)>3 else ''
g=load(sys.argv[1],filt); o=load(sys.argv[2],filt)
gk=collections.defaultdict(list); ok=collections.defaultdict(list)
for (k,v),c in g.items(): gk[k]+= [v]*c
for (k,v),c in o.items(): ok[k]+= [v]*c
shared=set(gk)&set(ok)
bad=[k for k in shared if sorted(gk[k])!=sorted(ok[k])]
print("shared keys",len(shared),"DIFFERING shared keys",len(bad),
      "gold-only keys",len(set(gk)-set(ok)),"ours-only keys",len(set(ok)-set(gk)))
# cluster differing shared keys by (G payload shape, O payload shape) normalised
def norm(v):
    import re
    return re.sub(r'HPNAME=[^\t]*','HPNAME=*',v)
cl=collections.Counter()
ex={}
for k in bad:
    sig=(tuple(sorted(norm(x) for x in gk[k])), tuple(sorted(norm(x) for x in ok[k])))
    cl[sig]+=1
    ex.setdefault(sig,k)
print("FAMILIES among differing shared keys:",len(cl))
for sig,c in cl.most_common(20):
    print("-"*100); print("count",c,"example key:",ex[sig])
    for x in sig[0]: print("  G:",x)
    for x in sig[1]: print("  O:",x)
