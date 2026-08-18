# r10rgg18repro/census18join.py — MULTISET join of two pacensus18 dumps.
#   usage: census18join.py <gold.txt> <ours.txt> [key-substring-filter] [-v]
# Keys collide by design (the same param_assign span appears once per gen-scope
# unrolling), so both sides are MULTISETS: a last-writer dict silently drops
# rows (RESUME §9 census traps).  Golden is always the FIRST file.
import sys, collections, re
def load(p, filt):
    d=collections.Counter()
    for ln in open(p):
        ln=ln.rstrip('\n')
        if '\t||\t' not in ln: continue
        k,v=ln.split('\t||\t',1)
        k=k.split('\t',1)[1]           # drop the tag column
        if filt and filt not in k: continue
        d[(k,v)]+=1
    return d
args=[a for a in sys.argv[1:] if not a.startswith('-')]
verbose='-v' in sys.argv
filt=args[2] if len(args)>2 else ''
g=load(args[0],filt); o=load(args[1],filt)
gk=collections.defaultdict(list); ok=collections.defaultdict(list)
for (k,v),c in g.items(): gk[k]+= [v]*c
for (k,v),c in o.items(): ok[k]+= [v]*c
shared=set(gk)&set(ok)
bad=[k for k in shared if sorted(gk[k])!=sorted(ok[k])]
print("rows G=%d O=%d | shared keys %d  DIFFERING shared keys %d  gold-only keys %d  ours-only keys %d"
      % (sum(g.values()), sum(o.values()), len(shared), len(bad),
         len(set(gk)-set(ok)), len(set(ok)-set(gk))))
def norm(v):
    return v
cl=collections.Counter(); ex={}
for k in bad:
    sig=(tuple(sorted(norm(x) for x in gk[k])), tuple(sorted(norm(x) for x in ok[k])))
    cl[sig]+=1; ex.setdefault(sig,k)
print("FAMILIES among differing shared keys:",len(cl))
for sig,c in cl.most_common(40 if not verbose else 10**6):
    print("-"*100); print("count",c,"example key:",ex[sig])
    for x in sig[0]: print("  G:",x)
    for x in sig[1]: print("  O:",x)
if verbose:
    for lbl,ks in (("GOLD-ONLY",sorted(set(gk)-set(ok))),("OURS-ONLY",sorted(set(ok)-set(gk)))):
        print("="*100); print(lbl,len(ks))
        for k in ks[:200]: print("  ",k,"|",gk.get(k,ok.get(k)))
