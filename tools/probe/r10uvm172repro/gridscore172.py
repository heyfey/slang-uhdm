#!/usr/bin/env python3
"""r10uvm172 — the grid scorer.  MEASUREMENT ONLY.

Reads one arm's three ct172list listings for ONE view (golden / pristine /
patched) and reports both

  raw   : plain diff-line count against golden (copy counts included)
  set   : diff-line count over the DEDUPED listings

because the two producers legitimately emit different COPY COUNTS of the same
package body (r10uvm170 residue R6): every arm here shows that difference in
BOTH binaries, identically, before and after, and a raw-only score would drown
the cells this law owns.  The DEF and ELAB listings are never merged
(r10uvm166 §6 / r10v169's listcheck law) — this script scores ONE view.

usage: gridscore172.py <workdir> <arm-name>
"""
import subprocess, sys, os

def rows(p):
    out = []
    for ln in open(p):
        i = ln.find(" home=")
        out.append(ln[:i] if i >= 0 else ln.rstrip("\n"))
    return out

def diffn(a, b):
    import difflib
    return sum(1 for l in difflib.unified_diff(a, b, n=0, lineterm="")
               if (l.startswith("+") or l.startswith("-"))
               and not l.startswith("+++") and not l.startswith("---"))

W, arm = sys.argv[1], sys.argv[2]
print("%-10s %-5s %6s %10s %10s %10s %10s" %
      ("ARM", "VIEW", "CELLS", "PRIS-raw", "PATCH-raw", "PRIS-set", "PATCH-set"))
for v in ("def", "elab"):
    g = rows(os.path.join(W, "list.g.%s.txt" % v))
    a = rows(os.path.join(W, "list.a.%s.txt" % v))
    b = rows(os.path.join(W, "list.b.%s.txt" % v))
    gs, as_, bs = sorted(set(g)), sorted(set(a)), sorted(set(b))
    print("%-10s %-5s %6d %10d %10d %10d %10d" %
          (arm, v, len(g), diffn(g, a), diffn(g, b), diffn(gs, as_), diffn(gs, bs)))
