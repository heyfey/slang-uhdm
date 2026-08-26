#!/usr/bin/env python3
"""r10v155 verifier — cell-level score, machine readable. LHS/G is ALWAYS golden."""
import sys, collections
def load(p):
    m = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 14 or f[1] in ("REF","CALL","TP"): continue
        m[(f[2], f[5], f[6], f[7])].add((f[8], f[10], f[11], f[12], f[13]))
    return m
g=load(sys.argv[1]); o=load(sys.argv[2])
for k in sorted(set(g)|set(o)):
    gv=sorted(g.get(k,[])); ov=sorted(o.get(k,[]))
    if not gv: tag="ONLY-O"
    elif not ov: tag="ONLY-G"
    elif gv==ov: tag="SAME"
    else: tag="DIFF"
    print("%s\t%s\tG=%s\tO=%s"%(tag,"|".join(k),gv,ov))
