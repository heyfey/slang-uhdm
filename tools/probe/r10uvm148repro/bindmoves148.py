#!/usr/bin/env python3
"""r10uvm148 — bound148.sh's check (4).  MEASUREMENT ONLY.

  bindmoves148.py <pristine.cen> <patched.cen>   ->  the BREACH count

Counts every reference cell whose BINDING moved in a direction this pass does
not own.  The two legal directions are the pass's two halves:

  function|task -> package   § tfItemLocalLosesToPkgVar148 proper — the TF-ITEM
                             body local displaced by the package listing;
  package -> function|task   the `ParallelBlockStatement` half of the shared
                             `condPredEarlyBound81` gate, where a reference
                             nested under a `fork` turns out to be EARLY bound
                             and keeps its own local.  Allowed ONLY on a row the
                             census marks FORK=1.

Anything else — a move to or from a third scope kind, or to or from UNBOUND —
is a breach.  Cells are matched as MULTISETS on an ID-FREE key.
"""
import sys, collections

def load(p):
    b = collections.defaultdict(list)
    for ln in open(p):
        if "ROW=REF" not in ln:
            continue
        d = dict(x.split("=", 1) for x in ln.rstrip("\n").split("|") if "=" in x)
        k = (d.get("HSPAN"), d.get("RSPAN"), d.get("RNAME"),
             d.get("HNAME"), d.get("SITE"))
        b[k].append((d.get("BSK"), d.get("FORK")))
    return b

P, Q = load(sys.argv[1]), load(sys.argv[2])
bad = 0
for k in set(P) | set(Q):
    a = collections.Counter(P.get(k, []))
    c = collections.Counter(Q.get(k, []))
    if a == c:
        continue
    for v, fk in (c - a).elements():          # what our side GAINED
        if v == "package":
            continue
        if v in ("function", "task") and fk == "1":
            continue
        bad += 1
    for v, fk in (a - c).elements():          # what our side LOST
        if v in ("function", "task"):
            continue
        if v == "package" and fk == "1":
            continue
        bad += 1
print(bad)
