#!/usr/bin/env python3
"""r10v83 — THE WHOLE-DATABASE 3-WAY MULTISET SCORER.  MEASUREMENT ONLY.
Reads three v83all row files (golden / pristine / patched) and scores EVERY
distinct row by its MULTIPLICITY in the three databases:
    TO-GOLDEN   patched matches golden's count, pristine did not
    AWAY        pristine matched golden's count, patched does not   (MUST BE 0)
    STILL       both differ from golden, or both agree
Only rows whose count changed between pristine and patched are reported.
  usage: score83v.py g.rows o.rows q.rows
"""
import sys, collections
def load(p):
    c = collections.Counter()
    with open(p) as f:
        for line in f: c[line.rstrip("\n")] += 1
    return c
G, O, Q = (load(p) for p in sys.argv[1:4])
keys = set(G) | set(O) | set(Q)
T = collections.Counter()
rows = []
for k in keys:
    g, o, q = G[k], O[k], Q[k]
    if o == q:
        T["UNCHANGED-agrees" if g == o else "UNCHANGED-differs"] += 1
        continue
    if q == g and o != g:   v = "TO-GOLDEN"
    elif o == g and q != g: v = "AWAY"
    else:                   v = "STILL"
    T[v] += 1
    rows.append((v, g, o, q, k))
for v, g, o, q, k in sorted(rows):
    print("%-10s g=%d o=%d q=%d  %s" % (v, g, o, q, k.replace("\t", " | ")))
for k, n in sorted(T.items()):
    print("%-20s %d" % (k, n), file=sys.stderr)
