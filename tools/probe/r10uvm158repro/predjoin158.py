#!/usr/bin/env python3
"""r10uvm158 — the A-PRIORI predicate, evaluated on ONE row's two PRISTINE
censuses (golden + ours).  MEASUREMENT ONLY.  G is ALWAYS golden.

Prints one line per BLK cell where golden LISTS variables on a statement block
and OUR PRISTINE database has NO vpiVariables VECTOR AT ALL (`-1`, the null
vector) at the same (owner, span, kind) key — i.e. exactly the population
section badBlockKeepsItsScope158 moves, named before any patched database
exists.  Also prints the reverse bucket (ours lists, golden does not), which
must stay EMPTY: that would be an AWAY cell hiding in the same predicate.

usage: predjoin158.py <cen.g.tsv> <cen.o.tsv>
"""
import sys, collections

def load(p):
    m = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 13 or f[1] != "BLK":
            continue
        m[(f[5], f[6], f[7])].add((f[8], f[9], f[12]))
    return m

g, o = load(sys.argv[1]), load(sys.argv[2])
for k in sorted(set(g) & set(o)):
    gn = {int(v[1]) for v in g[k]}
    on = {int(v[1]) for v in o[k]}
    if any(x > 0 for x in gn) and on == {-1}:
        print("PRED-TOWARD\t%s\t%s\t%s\tG=%s\tO=%s"
              % (k[0], k[1], k[2], sorted(g[k]), sorted(o[k])))
    elif any(x > 0 for x in on) and gn == {-1}:
        print("PRED-AWAY\t%s\t%s\t%s\tG=%s\tO=%s"
              % (k[0], k[1], k[2], sorted(g[k]), sorted(o[k])))
