#!/usr/bin/env python3
"""r10uvm142 — A-PRIORI MOVER PREDICTOR.  MEASUREMENT ONLY (uhdm-cmp judges).

  pred142.py <golden.cen> <ours-pristine.cen>

Names, from the PRISTINE databases ALONE (no patched binary exists when this is
run), every `class_typespec` cell that
§ `tfItemLocalClassTsNamedByCompileTypespec142` is allowed to move.

The law fires on a SUBROUTINE BODY LOCAL compiled under Surelog's TF-ITEM
production, and that production is directly visible in golden's database: a
tf-item local is listed on the SUBROUTINE ITSELF (the holding `class_var`'s
vpiParent is a `function`/`task`), while a BLOCK-item local is re-parented under
the body `begin` (or, when it carries an initialiser, under that init
`assignment`).  So the predicate is

   GOLDEN has, at (span, class_defn), a NAMED class_typespec whose holder hangs
   off a function/task
   AND
   OURS has, at the same (span, class_defn), an ANONYMOUS class_typespec whose
   holder hangs off a function / task / begin / assignment
        (all four, because OUR side re-parents an INITIALISED local under its
         init assignment — a dump-only difference no Compare reads, but one
         that would otherwise split the pair)

and the predicted count per cell is the min of the two multiplicities.

Output: one line per predicted cell, then TOTAL.  A row printing TOTAL=0 is
predicted BYTE-IDENTICAL after the patch.
"""
import sys, collections

SUBHOLD_G = ("@function", "@task")
SUBHOLD_O = ("@function", "@task", "@begin", "@assignment")
# ...and only a DECLARED VARIABLE's typespec: a formal's holder is an `io_decl`
# and a return value's is marked "@ret" by ct142cen, and neither is this law's
# population.
HOLDKIND = ("class_var", "array_var")

def isvar(h):
    return any(h.startswith(k) for k in HOLDKIND)

def load(p):
    b = collections.defaultdict(list)
    try:
        for ln in open(p):
            if not ln.startswith("HOLD="):
                continue
            d = {}
            for f in ln.rstrip("\n").split("|"):
                k, v = f.split("=", 1)
                d[k] = v
            b[(d["TSSPAN"], d["TSDEFN"])].append(d)
    except FileNotFoundError:
        pass
    return b

g, p = load(sys.argv[1]), load(sys.argv[2])
tot = 0
for k in sorted(set(g) & set(p)):
    gn = sum(1 for r in g[k]
             if r["TSNAME"] != "-" and isvar(r["HOLD"])
             and any(h in r["HOLD"] for h in SUBHOLD_G))
    if not gn:
        continue
    on = sum(1 for r in p[k]
             if r["TSNAME"] == "-" and isvar(r["HOLD"])
             and any(h in r["HOLD"] for h in SUBHOLD_O))
    n = min(gn, on)
    if n > 0:
        tot += n
        names = sorted({r["TSNAME"] for r in g[k] if r["TSNAME"] != "-"})
        print("CELL %-18s n=%d NAME=%s DEFN=%s GOLDEN_TF=%d OURS_ANON=%d" %
              (k[0], n, ",".join(names), k[1], gn, on))
print("TOTAL=%d" % tot)
