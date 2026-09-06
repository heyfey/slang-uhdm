#!/usr/bin/env python3
"""r10uvm180 — the three-way arm scorer.

Joins one arm's GOLDEN, PRISTINE and PATCHED cell dumps (ct180grid output, one
line per cell: <tag>\\t<key>\\t<value>) and reports the only four verdicts that
matter for a landing:

  TOGOLD       pristine disagreed with golden, patched agrees      (the law)
  AWAY         pristine agreed with golden, patched does not       (must be 0)
  MOVED-WRONG  patched changed the cell to a THIRD value           (must be 0)
  STILL-WRONG  both disagree with golden, unchanged                (a residue)
  AGREE-BOTH   both agree with golden                              (the floor)

Keys present on only one side are reported separately and never scored: a key
gap is a pairing problem, not a movement, and counting one as a movement is how
a NODEDUP census manufactures AWAY-GOLDEN phantoms (RESUME.md §9).

usage: score180.py <cen.g.txt> <cen.a.txt> <cen.b.txt> [label]
"""
import sys
from collections import OrderedDict


def load(path):
    d = OrderedDict()
    with open(path) as f:
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 3:
                continue
            d[parts[1]] = parts[2]
    return d


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        return 2
    G, A, B = (load(p) for p in sys.argv[1:4])
    label = sys.argv[4] if len(sys.argv) > 4 else "arm"
    keys = set(G) | set(A) | set(B)
    togold = away = movedwrong = stillwrong = agreeboth = 0
    onlyg = onlya = onlyb = 0
    for k in sorted(keys):
        g, a, b = G.get(k), A.get(k), B.get(k)
        if g is None:
            onlyg += 0
            if a is not None or b is not None:
                print("NO-GOLDEN   %s  pris=%s  pat=%s" % (k, a, b))
            continue
        if a is None or b is None:
            if a is None:
                onlya += 1
            if b is None:
                onlyb += 1
            print("KEY-GAP     %s  gold=%s pris=%s pat=%s" % (k, g, a, b))
            continue
        if a == g and b == g:
            agreeboth += 1
        elif a != g and b == g:
            togold += 1
            print("TOGOLD      %s  gold=%s  was=%s" % (k, g, a))
        elif a == g and b != g:
            away += 1
            print("AWAY        %s  gold=%s  now=%s" % (k, g, b))
        elif a != g and b != g and a != b:
            movedwrong += 1
            print("MOVED-WRONG %s  gold=%s  was=%s  now=%s" % (k, g, a, b))
        else:
            stillwrong += 1
            print("STILL-WRONG %s  gold=%s  both=%s" % (k, g, a))
    print("SCORE %s TOGOLD=%d AWAY=%d MOVED-WRONG=%d STILL-WRONG=%d "
          "AGREE-BOTH=%d KEY-GAP-pris=%d KEY-GAP-pat=%d cells=%d"
          % (label, togold, away, movedwrong, stillwrong, agreeboth, onlya,
             onlyb, len(keys)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
