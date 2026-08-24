#!/usr/bin/env python3
"""r10earl83 — THE 3-WAY ARM SCORER.  MEASUREMENT ONLY.

Reads an arm directory produced by `arm83.sh` (g.rows / o.rows / q.rows) and
prints ONE LINE PER CELL, keyed by SPAN+CTX+PORTPAR+CALLARG+PSBOUND, with the
GOLDEN / PRISTINE / PATCHED payloads and a verdict:

    SAME->SAME     agreed before, agrees after       (must never change)
    WRONG->RIGHT   a MOVER that landed on golden      (the law working)
    WRONG->WRONG   still wrong, payload UNCHANGED     (an abstention)
    WRONG->OTHER   still wrong, payload CHANGED       (moved, not to golden)
    RIGHT->WRONG   A REGRESSION                       (must be 0)
    G-ONLY / O-ONLY / Q-ONLY  one side has no object at that key

Multiset joined (a dict would drop colliding rows).  The payload carries no
span-derived field beyond the key.
  usage: score3_83.py <armdir> [--all]
"""
import sys, os, collections

def load(p):
    rows = collections.defaultdict(list)
    if not os.path.exists(p): return rows
    for line in open(p):
        line = line.rstrip("\n")
        if "\t||\t" not in line: continue
        k, v = line.split("\t||\t", 1)
        rows[k].append(v)
    for k in rows: rows[k].sort()
    return rows

d = sys.argv[1]
showall = "--all" in sys.argv
G, O, Q = (load(os.path.join(d, x + ".rows")) for x in ("g", "o", "q"))
keys = sorted(set(G) | set(O) | set(Q))
T = collections.Counter()
for k in keys:
    g, o, q = G.get(k, []), O.get(k, []), Q.get(k, [])
    n = max(len(g), len(o), len(q))
    for i in range(n):
        gv = g[i] if i < len(g) else None
        ov = o[i] if i < len(o) else None
        qv = q[i] if i < len(q) else None
        if gv is None or ov is None or qv is None:
            v = "MISSING(g=%d o=%d q=%d)" % (len(g), len(o), len(q))
        elif gv == ov and gv == qv: v = "SAME->SAME"
        elif gv != ov and gv == qv: v = "WRONG->RIGHT"
        elif gv != ov and ov == qv: v = "WRONG->WRONG"
        elif gv == ov and gv != qv: v = "RIGHT->WRONG"
        else: v = "WRONG->OTHER"
        T[v] += 1
        if showall or v not in ("SAME->SAME",):
            def sh(x):
                if x is None: return "<none>"
                return " ".join(f for f in x.split("\t")
                                if not f.endswith("=-"))
            print("%-14s %s\n      G %s\n      O %s\n      Q %s" %
                  (v, k, sh(gv), sh(ov), sh(qv)))
for k, n in sorted(T.items()):
    print("%-22s %d" % (k, n), file=sys.stderr)
