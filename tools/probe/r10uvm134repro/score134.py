#!/usr/bin/env python3
"""r10uvm134 — FOREACH cell scorer.  MEASUREMENT ONLY (uhdm-cmp is the judge).

  score134.py <golden.cen> <pristine.cen> [<patched.cen>]

Cells are the rows ct134cen prints, joined as a MULTISET (keys collide across
instances; a last-writer dict drops rows) on the ID-FREE key

    HOME | PATH | SPAN | NLV | LVNAMES

SPAN is the foreach_stmt's OWN span (the `foreach` keyword), which both sides
already agree on for every cell in the corpus — it is a LOCATOR here, not a
scored column; the Variable's own span (VSPAN) is scored separately and is
dump-only (uhdm-cmp never reads VpiLineNo).

Scored columns:
  VKIND   the Variable() slot's kind        <- THE HEAD (VpiType, read by Compare)
  VNAME   the Variable() slot's VpiName     <- read by Compare
  VTS     its actual typespec's kind        <- reached through ref_typespec
  VTSNAME that typespec's VpiName
  LVKINDS the loop variables' kinds         <- read by Compare
  LVTS    the loop variables' typespec kinds
  VFULL   dump-only (VpiFullName is NOT read by Compare) — diagnostic
  VSPAN   dump-only

Verdicts per cell and per column:
  RIGHT->RIGHT / WRONG->RIGHT (fixed) / WRONG->WRONG / RIGHT->WRONG (MOVED-WRONG,
  must be 0) / ONLY-GOLDEN / ONLY-OURS / AWAY (a key that left or entered our
  side because of the patch — must be 0).
"""
import sys, collections

COLS = ("VKIND", "VNAME", "VTS", "VTSNAME", "LVKINDS", "LVTS", "VFULL", "VSPAN")

def load(p):
    rows = []
    try:
        for ln in open(p):
            ln = ln.rstrip("\n")
            if not ln.startswith("VKIND="):
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
    return (r["HOME"], r["PATH"], r["SPAN"], r["NLV"], r["LVNAMES"])

def bag(rows):
    b = collections.defaultdict(list)
    for r in rows:
        b[key(r)].append(r)
    return b

args = sys.argv[1:]
g = bag(load(args[0]))
p = bag(load(args[1]))
q = bag(load(args[2])) if len(args) > 2 else p
keys = set(g) | set(p) | set(q)
LIM = int(__import__("os").environ.get("LIM", "60"))

for col in COLS:
    c = collections.Counter(); detail = []
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
    for v, k, i, gv, pv, qv in detail[:LIM]:
        print("   %-13s g=%s pris=%s pat=%s  #%d  %s" % (v, gv, pv, qv, i, "|".join(k)))
    if len(detail) > LIM:
        print("   ... %d more" % (len(detail) - LIM))
