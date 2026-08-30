#!/usr/bin/env python3
# Per-key disagreement sets vs golden, pristine vs patched.  Reports any key
# that is RIGHT on pristine and WRONG on patched (a regression) and the totals.
import sys, collections
def load(p):
    c=collections.Counter()
    for ln in open(p):
        ln=ln.rstrip('\n')
        if not ln: continue
        n,k,v=ln.split('\t',2); c[(k,v)]+=int(n)
    return c
def bykey(c):
    d=collections.defaultdict(collections.Counter)
    for (k,v),n in c.items(): d[k][v]+=n
    return d
G,P,Q=[bykey(load(x)) for x in sys.argv[1:4]]
keys=set(G)|set(P)|set(Q)
def agree(a,b,k):
    # compare the SET of payloads present (copy counts are sharing, not compare-visible)
    return set(a.get(k,{}))==set(b.get(k,{}))
pw=[k for k in keys if not agree(G,P,k)]
qw=[k for k in keys if not agree(G,Q,k)]
reg=[k for k in qw if k not in pw]
fix=[k for k in pw if k not in qw]
print('KEYS %d  PRISTINE-WRONG %d  PATCHED-WRONG %d  FIXED %d  REGRESSED %d'
      % (len(keys), len(pw), len(qw), len(fix), len(reg)))
for k in reg:
    print('  REGRESSION', k)
    print('    gold ', sorted(G.get(k,{})))
    print('    pris ', sorted(P.get(k,{})))
    print('    pat  ', sorted(Q.get(k,{})))
