#!/usr/bin/env python3
# r10v79 — THE ONLY QUESTION THAT DECIDES A REGRESSION: is there a key that
# PRISTINE GOT RIGHT (O == G, G > 0) and the patched binary does not?
import sys, collections
def load(p, judge=True):
    c=collections.Counter()
    for l in open(p):
        l=l.rstrip('\n'); c[l.split(' || SPANS:')[0] if judge else l]+=1
    return c
def run(tag, judge):
    g,o,q=(load(sys.argv[i],judge) for i in (1,2,3))
    broke=[]; fixed=0
    for k in set(g)|set(o)|set(q):
        if g[k]>0 and o[k]==g[k] and q[k]!=g[k]: broke.append((g[k],o[k],q[k],k))
        if g[k]>0 and o[k]!=g[k] and q[k]==g[k]: fixed+=1
    print("%s  PRISTINE-RIGHT->PATCHED-WRONG keys=%d   newly-exact keys=%d" % (tag,len(broke),fixed))
    for b in broke[:10]: print("   BROKE G=%d O=%d Q=%d %s" % b)
run("JUDGE ", True); run("SPANS ", False)
