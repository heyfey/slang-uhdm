#!/usr/bin/env python3
"""Three-way multiset score for ev101.py output: golden, pristine, patched."""

import collections
import sys


def load(path):
    out = collections.defaultdict(list)
    with open(path, encoding="utf-8") as inp:
        for line in inp:
            cols = line.rstrip("\n").split("\t", 1)
            if len(cols) == 2:
                out[cols[0]].append(cols[1])
    return out


gold, pristine, patched = map(load, sys.argv[1:4])
counts = collections.Counter()
for key in sorted(set(gold) | set(pristine) | set(patched)):
    g = sorted(gold.get(key, []))
    p = sorted(pristine.get(key, []))
    q = sorted(patched.get(key, []))
    if p == g and q == g:
        verdict = "STILL-RIGHT"
    elif p != g and q == g:
        verdict = "TO-GOLDEN"
    elif p == g and q != g:
        verdict = "AWAY-GOLDEN"
    else:
        verdict = "STILL-WRONG"
    counts[verdict] += 1
    if verdict != "STILL-RIGHT":
        print("%s\t%s\n  G=%s\n  P=%s\n  Q=%s" %
              (verdict, key, g, p, q))

print("COUNTS " + " ".join("%s=%d" % (k, counts[k]) for k in
      ("STILL-RIGHT", "TO-GOLDEN", "AWAY-GOLDEN", "STILL-WRONG")))
