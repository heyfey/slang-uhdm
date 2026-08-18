import sys
from collections import defaultdict
def load(p):
    d=defaultdict(list)
    for ln in open(p):
        f=ln.rstrip('\n').split(' ')
        d[' '.join(f[:5])].append(f[5:])
    return d
g,o,q=load(sys.argv[1]),load(sys.argv[2]),load(sys.argv[3])
better=worse=same=0; rows=[]
for k in set(g)|set(o)|set(q):
    G,O,Q=sorted(g.get(k,[])),sorted(o.get(k,[])),sorted(q.get(k,[]))
    n=max(len(G),len(O),len(Q))
    for i in range(n):
        gg=G[i] if i<len(G) else []; oo=O[i] if i<len(O) else []; qq=Q[i] if i<len(Q) else []
        if oo==qq: continue
        so=sum(1 for a,b in zip(gg,oo) if a==b); sq=sum(1 for a,b in zip(gg,qq) if a==b)
        if sq>so: better+=1
        elif sq<so: worse+=1; rows.append((k,gg,oo,qq))
        else: same+=1; rows.append((k,gg,oo,qq))
print('BETTER',better,'WORSE',worse,'EQUAL',same)
for k,gg,oo,qq in rows[:6]:
    print(' ',k); print('   G',' '.join(gg)); print('   O',' '.join(oo)); print('   P',' '.join(qq))
