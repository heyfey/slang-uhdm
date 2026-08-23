import sys, collections, re
def load(p):
    d=collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('RG '): continue
        f=ln.rstrip('\n').split(' ',2)
        d[f[1]].append(f[2])
    for k in d: d[k].sort()
    return d
G,O=load(sys.argv[1]),load(sys.argv[2])
c=collections.Counter(); tot=0; diff=0
for k in G:
    if k not in O: continue
    g,o=G[k],O[k]
    for i in range(min(len(g),len(o))):
        tot+=1
        if g[i]!=o[i]:
            diff+=1
            # classify: only ct/tag differ?
            gg=re.sub(r'ct=\d+','ct=',g[i]); oo=re.sub(r'ct=\d+','ct=',o[i])
            gg=re.sub(r'val=[A-Z]+:','val=:',gg); oo=re.sub(r'val=[A-Z]+:','val=:',oo)
            c['CT/TAG-ONLY' if gg==oo else 'OTHER']+=1
print('shared range cells',tot,'DIFFERING',diff, dict(c))
seen=collections.Counter()
for k in sorted(G):
    if k not in O: continue
    g,o=G[k],O[k]
    for i in range(min(len(g),len(o))):
        if g[i]!=o[i]:
            gg=re.sub(r'ct=\d+','ct=',g[i]); oo=re.sub(r'ct=\d+','ct=',o[i])
            gg=re.sub(r'val=[A-Z]+:','val=:',gg); oo=re.sub(r'val=[A-Z]+:','val=:',oo)
            if gg!=oo: continue
            seen[(g[i],o[i])]+=1
for (a,b),n in seen.most_common(10):
    print('x%d\n  G:%s\n  O:%s'%(n,a,b))
