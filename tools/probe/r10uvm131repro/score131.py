#!/usr/bin/env python3
"""r10uvm131 — FORK cell scorer.  MEASUREMENT ONLY (uhdm-cmp is the judge).

  score131.py <golden.cen> <pristine.cen> <patched.cen>

Cells are the rows ct131cen prints, joined on the SPAN-FREE, ID-FREE key
    KIND | NAME | ENDLBL | NSTMT | PATH
as a MULTISET (keys collide across instances; a last-writer dict drops rows).

Scored columns: JOIN (the head's field, read by named_fork::Compare and
fork_stmt::Compare) and SPAN (dump-only — uhdm-cmp never reads VpiLineNo).

Verdicts per cell, computed for JOIN and for SPAN separately:
  RIGHT->RIGHT  agreed with golden before and after
  WRONG->RIGHT  FIXED by the patch
  WRONG->WRONG  still wrong (value may have changed: printed)
  RIGHT->WRONG  MOVED-WRONG   (must be 0)
  ONLY-GOLDEN   a golden cell with no cell of ours (both sides)
  ONLY-OURS     a cell of ours with no golden cell (both sides)
AWAY = a cell whose key left/entered our side because of the patch.
"""
import sys, collections

def load(p):
    rows = []
    try:
        for ln in open(p):
            ln = ln.rstrip("\n")
            if not ln.startswith("KIND="):
                continue
            d = {}
            for f in ln.split("|"):
                if "=" in f:
                    k, v = f.split("=", 1)
                    d[k] = v
            rows.append(d)
    except FileNotFoundError:
        pass
    return rows

def key(r):
    return (r["KIND"], r["NAME"], r["ENDLBL"], r["NSTMT"], r["PATH"])

def bag(rows):
    b = collections.defaultdict(list)
    for r in rows:
        b[key(r)].append(r)
    return b

g, p, q = (bag(load(a)) for a in sys.argv[1:4])
keys = set(g) | set(p) | set(q)

def cnt():
    return collections.Counter()

for col in ("JOIN", "SPAN"):
    c = cnt(); detail = []
    for k in sorted(keys):
        gs, ps, qs = g.get(k, []), p.get(k, []), q.get(k, [])
        n = max(len(gs), len(ps), len(qs))
        for i in range(n):
            gv = gs[i][col] if i < len(gs) else None
            pv = ps[i][col] if i < len(ps) else None
            qv = qs[i][col] if i < len(qs) else None
            if gv is None and pv is None and qv is None:
                continue
            if gv is None:
                c["ONLY-OURS"] += 1
                detail.append(("ONLY-OURS", k, i, gv, pv, qv)); continue
            if pv is None and qv is None:
                c["ONLY-GOLDEN"] += 1
                detail.append(("ONLY-GOLDEN", k, i, gv, pv, qv)); continue
            if pv is None or qv is None:
                c["AWAY"] += 1
                detail.append(("AWAY", k, i, gv, pv, qv)); continue
            a, b = (pv == gv), (qv == gv)
            v = ("RIGHT->RIGHT" if (a and b) else
                 "WRONG->RIGHT" if (not a and b) else
                 "RIGHT->WRONG" if (a and not b) else "WRONG->WRONG")
            c[v] += 1
            if v != "RIGHT->RIGHT":
                detail.append((v, k, i, gv, pv, qv))
    tot = sum(c.values())
    print("%s: TOTAL=%d %s" % (col, tot,
          " ".join("%s=%d" % (k, c[k]) for k in
                   ("RIGHT->RIGHT", "WRONG->RIGHT", "WRONG->WRONG",
                    "RIGHT->WRONG", "ONLY-GOLDEN", "ONLY-OURS", "AWAY")
                   if c[k])))
    for v, k, i, gv, pv, qv in detail[:60]:
        print("   %-13s g=%s pris=%s pat=%s  #%d  %s" % (v, gv, pv, qv, i, "|".join(k)))
    if len(detail) > 60:
        print("   ... %d more" % (len(detail) - 60))
