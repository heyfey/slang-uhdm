#!/usr/bin/env python3
# r10v79 STRICT scorer: per-key |G-O| vs |G-Q| on the JUDGE HALF.
# Any key where |G-Q| > |G-O| is a cell the patch moved AWAY from golden.
import sys, collections
def load(p, judge=True):
    c=collections.Counter()
    for l in open(p):
        l=l.rstrip('\n')
        c[l.split(' || SPANS:')[0] if judge else l]+=1
    return c
g,o,q=(load(sys.argv[i]) for i in (1,2,3))
worse=better=0; wkeys=[]
for k in set(g)|set(o)|set(q):
    do=abs(g[k]-o[k]); dq=abs(g[k]-q[k])
    if dq>do: worse+=dq-do; wkeys.append((dq-do,g[k],o[k],q[k],k))
    elif dq<do: better+=do-dq
print("JUDGE-HALF  improved=%d  WORSENED=%d  dist(g,o)=%d dist(g,q)=%d" %
      (better, worse, sum(abs(g[k]-o[k]) for k in set(g)|set(o)),
       sum(abs(g[k]-q[k]) for k in set(g)|set(q))))
for w in sorted(wkeys, reverse=True)[:12]:
    print("  WORSE +%d G=%d O=%d Q=%d %s" % w)
sg,so,sq=(load(sys.argv[i],False) for i in (1,2,3))
sw=sb=0
for k in set(sg)|set(so)|set(sq):
    do=abs(sg[k]-so[k]); dq=abs(sg[k]-sq[k])
    if dq>do: sw+=dq-do
    elif dq<do: sb+=do-dq
print("WITH-SPANS  improved=%d  WORSENED=%d" % (sb, sw))
