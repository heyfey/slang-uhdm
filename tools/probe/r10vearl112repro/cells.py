import sys
from collections import Counter,defaultdict
def load(p):
    d=defaultdict(Counter)
    for line in open(p):
        parts=line.rstrip('\n').split('\t')
        if len(parts)<3 or parts[0].startswith('CENRC'): continue
        if '|HPN|' not in parts[0]: continue
        d[parts[0]][parts[1]]+=int(parts[2])
    return d
g=load(sys.argv[1]);p=load(sys.argv[2]);a=load(sys.argv[3])
def shp(c): return frozenset(k.split(',IX')[0] for k in c)
out=Counter()
for k in sorted(set(g)|set(p)|set(a)):
    G,P,A=shp(g[k]),shp(p[k]),shp(a[k])
    if not g.get(k): v='O-ONLY'
    elif not (p.get(k) or a.get(k)): v='G-ONLY'
    else: v='SAME' if (P==G and A==G) else ('TOGOLD' if (P!=G and A==G) else ('AWAY' if (P==G and A!=G) else ('MOVEDWRONG' if P!=A else 'STILLWRONG')))
    out[v]+=1
    if v in ('AWAY','MOVEDWRONG','TOGOLD','STILLWRONG') or len(sys.argv)>4:
        print(v, k.split('|')[-1], '| G=',sorted(G),'| P=',sorted(P),'| A=',sorted(A))
print('TALLY', dict(out))
