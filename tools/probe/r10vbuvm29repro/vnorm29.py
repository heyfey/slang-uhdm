#!/usr/bin/env python3
"""r10vbuvm29 VIEW-GENERAL three-way dump comparator.  MEASUREMENT ONLY.

Reads three uhdm-dump texts (GOLDEN, PRISTINE, PATCHED) and compares them as
MULTISETS of NORMALISED lines.  The normalisation drops exactly the things no
generated `Compare` reads (RESUME.md §9): object ids, absolute file paths,
and line:col spans.  What survives is kind + names + the per-kind fields the
judge does read (vpiOpType, vpiValue, vpiTypespec/vpiActual chains,
vpiDirection, ...), plus the indentation depth as a structure proxy.

Verdicts, per normalised line:
  TO-GOLDEN    pristine's count differed from golden, patched's matches
  AWAY-GOLDEN  pristine's count matched golden, patched's does not  <-- must be 0
  STILL        both differ
  (agreeing lines are silent)

usage: vnorm29.py G.dump PRI.dump PAT.dump [-v]
"""
import re, sys
from collections import Counter

ID  = re.compile(r", id:\d+")
LOC = re.compile(r"(, )?line:\d+:\d+(, endln:\d+:\d+)?")
FIL = re.compile(r"\|vpiFile:.*")
PTH = re.compile(r"/[A-Za-z0-9_./+-]*/")

def norm(path, nodepth=False):
    c = Counter()
    for ln in open(path, errors="replace"):
        ln = ln.rstrip("\n")
        if ln.startswith("Restored design") or ln.startswith("Dumping"):
            continue
        depth = len(ln) - len(ln.lstrip())
        s = ln.strip()
        s = ID.sub("", s)
        s = LOC.sub("", s)
        s = FIL.sub("|vpiFile:<f>", s)
        s = PTH.sub("<p>/", s)
        c[(0 if nodepth else depth, s)] += 1
    return c

def main():
    nodepth = "--nodepth" in sys.argv
    g, p, q = (norm(a, nodepth) for a in sys.argv[1:4])
    verbose = "-v" in sys.argv
    keys = set(g) | set(p) | set(q)
    t = Counter()
    rows = []
    for k in sorted(keys):
        gg, pp, qq = g[k], p[k], q[k]
        if gg == pp and gg == qq:
            continue
        if gg != pp and gg == qq:
            v = "TO-GOLDEN"
        elif gg == pp and gg != qq:
            v = "AWAY-GOLDEN"
        elif pp == qq:
            v = "STILL"
        else:
            v = "STILL-MOVED"
        t[v] += 1
        rows.append((v, k, gg, pp, qq))
    if verbose:
        for v, k, gg, pp, qq in rows:
            print(f"  {v:12s} G{gg} P{pp} Q{qq}  d{k[0]} {k[1][:150]}")
    print(("NODEPTH " if nodepth else "") + "NORMLINES %d  " % len(keys) +
          "  ".join(f"{o} {t[o]}" for o in
                    ["TO-GOLDEN", "AWAY-GOLDEN", "STILL", "STILL-MOVED"]))

main()
