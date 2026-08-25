#!/usr/bin/env python3
"""r10uvm139 — VARIABLE-LIFETIME cell scorer.  MEASUREMENT ONLY (uhdm-cmp is
the judge).

  score139.py <golden.cen> <pristine.cen> [<patched.cen>]

Cells are the rows ct139cen prints, joined as a MULTISET (keys collide across
instances; a last-writer dict drops rows) on the ID-FREE key

    SCOPE | VNAME

and, within a key, ordered by PATH (stable per producer, and identical in
pristine and patched — this pass changes no parent pointer).

Neither SPAN nor PATH is in the key.  The two producers disagree about a
variable's own span AND about its parent on exactly the population this pass
measures (an initialised TF-ITEM local anchors at the declared type and hangs
off the subroutine in golden; here it anchors at the name and a PACKAGE free
function re-parents it under the body `begin`'s init assignment) — and
`variables::Compare` reads NEITHER a location NOR VpiParent, so either in the
key would split cells that the judge pairs.  Both are scored as separate
DUMP-ONLY columns instead.

Scored columns:
  AUTO    vpiAutomatic                <- THE HEAD (variables::Compare reads it)
  VKIND   the object's kind           <- read by Compare (VpiType)
  VTS     its actual typespec's kind  <- reached through ref_typespec
  VCONST  vpiConstantVariable         <- read by Compare
  PATH    dump-only (no generated Compare reads VpiParent) — diagnostic
  VFULL   dump-only (VpiFullName is NOT read by Compare) — diagnostic
  VSPAN   dump-only

Verdicts per cell and per column:
  RIGHT->RIGHT / WRONG->RIGHT (fixed) / WRONG->WRONG / RIGHT->WRONG (MOVED-WRONG,
  must be 0) / ONLY-GOLDEN / ONLY-OURS / AWAY (a key that left or entered our
  side because of the patch — must be 0).
"""
import sys, collections, os

COLS = ("AUTO", "VKIND", "VTS", "VCONST", "PATH", "VFULL", "VSPAN")

# UHDM's built-in classes.  A Surelog golden built with `-nobuiltin` (every
# grid arm here) does not carry them, and our exporter always does — they are
# NOT this pass's population and would read as permanent ONLY-OURS noise.
# Set BUILTINS=1 to keep them.
BUILTIN = ("class_defn(work@mailbox)", "class_defn(work@process)",
           "class_defn(work@semaphore)")
KEEP_BUILTIN = os.environ.get("BUILTINS", "") == "1"

def load(p):
    rows = []
    try:
        for ln in open(p):
            ln = ln.rstrip("\n")
            if not ln.startswith("AUTO="):
                continue
            d = {}
            for f in ln.split("|"):
                if "=" in f:
                    k, v = f.split("=", 1)
                    d[k] = v
            if not KEEP_BUILTIN and any(b in d.get("PATH", "") for b in BUILTIN):
                continue
            rows.append(d)
    except FileNotFoundError:
        pass
    return rows

def key(r):
    return (r["SCOPE"], r["VNAME"])

def bag(rows):
    b = collections.defaultdict(list)
    for r in rows:
        b[key(r)].append(r)
    for v in b.values():
        v.sort(key=lambda r: r["PATH"])
    return b

args = sys.argv[1:]
g = bag(load(args[0]))
p = bag(load(args[1]))
q = bag(load(args[2])) if len(args) > 2 else p
keys = set(g) | set(p) | set(q)
LIM = int(os.environ.get("LIM", "60"))

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
