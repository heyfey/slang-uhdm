#!/usr/bin/env python3
"""r11u84 PER-CELL REGRESSION SCORER — pristine-right -> patched-wrong.

Scores the PACKAGE SECTION of both views, PER CELL, three ways at once:
  TO-GOLDEN    the cell was wrong on pristine and is right on patched
  AWAY-GOLDEN  the cell was RIGHT on pristine and is wrong on patched  (fatal)
  STILL-WRONG  wrong on both

A cell is one entry of one package's listing in one view, identified by its
POSITION in the ordered vector as well as by its face, so a pure SLOT move
(r11u84 LAW C's whole surface) is scored rather than washed out — an
order-blind multiset scorer reads LAW C as a no-op.  The face is
pkgscore79's: kind + the judge-read fields, no span, no fullname.

usage: reg84.py <grid-dir> [arms...]
"""
import os, sys, difflib

SRC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pkgscore79.py")
ns = {}
exec(open(SRC).read().split("def main()")[0], ns)
parse, face = ns["parse"], ns["face"]

GRID = sys.argv[1]
ARMS = sys.argv[2:] or sorted(os.listdir(GRID))
SECTS = ("uhdmallPackages", "uhdmtopPackages")


def cells(fn, sect):
    out = {}
    for r in parse(fn):
        if r[0] != sect:
            continue
        nm = r[4].strip("()")
        out.setdefault(nm.split("::")[0], []).append(
            nm.split("::")[-1] + "|" + face(r))
    return out


tot = dict(to=0, away=0, still=0, ok=0)
for a in ARMS:
    d = os.path.join(GRID, a)
    fs = [os.path.join(d, f) for f in
          ("gold.p1.dump", "ours.pris.dump", "ours.p1.dump")]
    if not all(os.path.exists(f) for f in fs):
        continue
    per = dict(to=0, away=0, still=0, ok=0)
    for sect in SECTS:
        G, P, Q = (cells(f, sect) for f in fs)
        for pkg in sorted(set(G) | set(P) | set(Q)):
            g, p, q = G.get(pkg, []), P.get(pkg, []), Q.get(pkg, [])
            # Align each side to golden by position, counting an inserted or
            # deleted entry as a wrong cell on that side.
            def wrong(x):
                sm = difflib.SequenceMatcher(None, g, x, autojunk=False)
                return sum(max(i2 - i1, j2 - j1)
                           for op, i1, i2, j1, j2 in sm.get_opcodes()
                           if op != "equal")
            wp, wq = wrong(p), wrong(q)
            n = max(len(g), len(p), len(q))
            per["ok"] += n - max(wp, wq)
            if wq < wp:
                per["to"] += wp - wq
                per["still"] += wq
            elif wq > wp:
                per["away"] += wq - wp
                per["still"] += wp
            else:
                per["still"] += wq
    if any(per[k] for k in ("to", "away", "still")):
        print("%-20s TO-GOLDEN=%-4d AWAY-GOLDEN=%-3d STILL-WRONG=%-4d"
              % (a, per["to"], per["away"], per["still"]))
    for k in tot:
        tot[k] += per[k]
print("TOTAL TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d CELLS-OK=%d"
      % (tot["to"], tot["away"], tot["still"], tot["ok"]))
