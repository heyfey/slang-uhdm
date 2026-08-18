#!/usr/bin/env python3
# vbuvm15 verifier: multiset join of two DEEP censuses, collapsed rows only.
import sys, collections
def load(path, only_coll=True):
    keyed = collections.defaultdict(collections.Counter)
    for line in open(path):
        if not line.startswith('CALL2 '): continue
        f = line.rstrip('\n').split(' ')
        d = {}
        for tok in f[2:]:
            k,_,v = tok.partition('=')
            d[k]=v
        if only_coll and d.get('coll')!='1': continue
        key=(f[1], d.get('key'), d.get('ck'), d.get('nm'), d.get('coll'),
             d.get('sub'), d.get('sk'), d.get('nref'))
        keyed[key][d.get('r','')] += 1
    return keyed
G=load(sys.argv[1]); O=load(sys.argv[2])
dis=0; arity=0; agree=0
dbs=set()
for k in sorted(set(G)|set(O)):
    g,o=G.get(k,collections.Counter()),O.get(k,collections.Counter())
    if sum(g.values())!=sum(o.values()):
        arity+=1; print('ARITY    %s\n    G:%s\n    O:%s'%('|'.join(map(str,k)),dict(g),dict(o))); continue
    if g==o: agree+=sum(g.values()); continue
    dis+=1; dbs.add(k[0])
    print('DISAGREE %s\n    G:%s\n    O:%s'%('|'.join(map(str,k)),dict(g-o),dict(o-g)))
print('TOTALS agree=%d disagree_keys=%d arity=%d'%(agree,dis,arity))
print('PREDICTED_DATABASES:')
for d in sorted(dbs): print('  '+d)
