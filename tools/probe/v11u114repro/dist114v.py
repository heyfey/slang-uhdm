import sys,re,collections
def load(p):
    L=[]
    for l in open(p,errors='replace'):
        l=re.sub(r'id:\d+','id:',l.rstrip('\n'))
        l=re.sub(r'/tmp/\S+','',l)
        L.append(l)
    return collections.Counter(L)
def dist(a,b): return sum(((a-b)+(b-a)).values())
for arm in sys.argv[1:]:
    g=load(f'{arm}/gold.dump'); p=load(f'{arm}/pris.dump'); w=load(f'{arm}/lawx.dump')
    # lines that changed between pris and law
    rem=p-w; add=w-p
    rem_in_gold=sum(min(c,g[k]) for k,c in rem.items()); add_in_gold=sum(min(c,g[k]) for k,c in add.items())
    print(f"{arm} dist pris={dist(g,p)} law={dist(g,w)} delta={dist(g,w)-dist(g,p)}  removed={sum(rem.values())}(inGold {rem_in_gold}) added={sum(add.values())}(inGold {add_in_gold})")
