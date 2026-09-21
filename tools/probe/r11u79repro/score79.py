#!/usr/bin/env python3
"""r11u79 arm scorer — gold-only / ours-only dump distance per arm.

Both dumps are path-normalised by the runner already.  The score is the
MULTISET difference of dump lines, so a line we write that golden does not is
counted once per occurrence (the multiset trap).  `ours_only` RISING on any arm
is a MOVED-WRONG signal; `gold_only` FALLING is a move toward golden.
"""
import os, sys, collections

GRID = os.environ.get("GRID") or (os.path.dirname(os.path.abspath(__file__)) + "/grid")
tags = sys.argv[1:] or ["pris", "patch"]

arms = sorted(d for d in os.listdir(GRID) if os.path.isdir(os.path.join(GRID, d)))
print("%-18s %s" % ("arm", "  ".join("%-22s" % ("gold_only/ours_only[%s]" % t) for t in tags)))
for a in arms:
    row = []
    for t in tags:
        g = os.path.join(GRID, a, "gold.%s.dump" % t)
        o = os.path.join(GRID, a, "ours.%s.dump" % t)
        if not (os.path.exists(g) and os.path.exists(o)):
            row.append("%-22s" % "-/-")
            continue
        gc = collections.Counter(open(g, errors="replace").read().splitlines())
        oc = collections.Counter(open(o, errors="replace").read().splitlines())
        row.append("%-22s" % ("%d/%d" % (sum((gc - oc).values()), sum((oc - gc).values()))))
    print("%-18s %s" % (a, "  ".join(row)))
