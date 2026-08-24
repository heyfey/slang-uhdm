#!/usr/bin/env python3
# r10earl78 — multiset DELTA of two/three tscen78 whole-design expression
# censuses (golden / pristine / patched).  Key = SEC + OWNER + SITE + PATH;
# payload = the kind and the judge fields, with every span= column STRIPPED
# (the span lives in the key, never in the payload — earl60 attrv60.py).
# MEASUREMENT ONLY.  usage: tsscore78.py <g.txt> <o.txt> <p.txt>
import sys, collections, re
DROP=re.compile(r'tsname=\S+ ')
def load(p):
    m=collections.Counter()
    for ln in open(p):
        f=ln.rstrip('\n').split(' ')
        if f[0]!='TS': continue
        # key = SEC OWNER SITE PATH ; payload = kind + judge fields (span kept
        # in the key, never the payload)
        key=(f[1],f[2],f[3],f[4])
        pay=' '.join(x for x in f[5:] if not x.startswith('span='))
        m[(key,pay)]+=1
    return m
g,o,p=(load(x) for x in sys.argv[1:4])
gk=collections.Counter(); ok=collections.Counter(); pk=collections.Counter()
for (k,v),n in g.items(): gk[k]+=n
for (k,v),n in o.items(): ok[k]+=n
for (k,v),n in p.items(): pk[k]+=n
print("cells g/o/p", sum(gk.values()), sum(ok.values()), sum(pk.values()))
# what CHANGED between pristine and patched
chg = (p - o) + (o - p)
print("pristine->patched differing multiset entries:", sum(chg.values()))
togold = sum(((p & g) - (o & g)).values())
awaygold = sum(((o & g) - (p & g)).values())
print("matched-with-golden entries: pristine", sum((o&g).values()), " patched", sum((p&g).values()),
      " NET", sum((p&g).values())-sum((o&g).values()))
for (k,v),n in sorted((p-o).items()):
    print("  NOW ", k, v, n)
for (k,v),n in sorted((o-p).items()):
    print("  WAS ", k, v, n)
