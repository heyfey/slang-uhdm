import sys,collections
def load(p,keyf):
    c=collections.Counter()
    for ln in open(p):
        ln=ln.rstrip('\n')
        if '\t||\t' not in ln: continue
        k,v=ln.split('\t||\t',1)
        f=dict(x.split('=',1) for x in k.split('\t') if '=' in x)
        key=tuple(f.get(x,'') for x in keyf)
        c[(key,v)]+=1
    return c
keyf=sys.argv[3].split(',')
G=load(sys.argv[1],keyf); O=load(sys.argv[2],keyf)
gk=collections.Counter(); ok=collections.Counter()
for (k,v),n in G.items(): gk[k]+=n
for (k,v),n in O.items(): ok[k]+=n
both=set(gk)&set(ok)
same=sum(min(G[(k,v)],O[(k,v)]) for (k,v) in set(G)&set(O))
gonly=sum(n for k,n in gk.items() if k not in ok)+sum(max(0,gk[k]-ok[k]) for k in both)
oonly=sum(n for k,n in ok.items() if k not in gk)+sum(max(0,ok[k]-gk[k]) for k in both)
movedw=sum(min(gk[k],ok[k]) for k in both)-same
print(f"golden={sum(gk.values())} ours={sum(ok.values())} BOTH-SAME={same} MOVED-WRONG={movedw} OURS-ONLY={oonly} GOLDEN-ONLY={gonly}")
for (k,v),n in sorted(O.items()):
    if G.get((k,v),0)<n: print("  OURS-EXTRA",n-G.get((k,v),0),k,v)
for (k,v),n in sorted(G.items()):
    if O.get((k,v),0)<n: print("  GOLD-EXTRA",n-O.get((k,v),0),k,v)
