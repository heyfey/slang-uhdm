#!/usr/bin/env python3
"""r10v174repro/vscore174.py — the VERIFIER's independent arm scorer.

MEASUREMENT ONLY.  Reads three ct174cen listings for ONE view (golden,
pristine, patched) and reports, per position, whether the patch moved us
TOWARD golden or AWAY from it.

A POSITION is (listing, home, name, line, col) — the source site a type query
was written at, with the LISTING read structurally so the two producers answer
it the same way.  Positions are NEVER merged across listings: a DEF-listing
cell and an ELAB-listing cell at the same line are different rows, which is
the whole point of the law under test.

  GOLDEN keeps p, we do not  -> we FOLD where golden KEEPS   (wrong)
  we keep p, GOLDEN does not  -> we KEEP where golden FOLDS   (wrong)

  TO-GOLDEN    p wrong in pristine, right in patched
  AWAY-GOLDEN  p right in pristine, wrong in patched   <-- must be 0
  STILL-WRONG  p wrong in both, same way
  UNCHANGED    p agrees in both

usage: vscore174.py <cen.g> <cen.a-pristine> <cen.b-patched> [--colblind]
"""
import sys


def load(path, colblind):
    keep = set()
    with open(path) as f:
        for ln in f:
            parts = ln.rstrip("\n").split("\t")
            if not parts or parts[0] != "KEEP":
                continue
            listing, home, name, line, col = parts[1:6]
            if colblind:
                keep.add((listing, home, name, line))
            else:
                keep.add((listing, home, name, line, col))
    return keep


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    colblind = "--colblind" in sys.argv
    g, a, b = (load(p, colblind) for p in args[:3])
    universe = g | a | b
    to_golden, away_golden, still_wrong, ours_only_pre = [], [], [], []
    for p in sorted(universe):
        gk, ak, bk = p in g, p in a, p in b
        pre_ok, post_ok = (ak == gk), (bk == gk)
        if not pre_ok and post_ok:
            to_golden.append(p)
        elif pre_ok and not post_ok:
            away_golden.append(p)
        elif not pre_ok and not post_ok:
            if gk:
                still_wrong.append(p)
            else:
                ours_only_pre.append(p)
    print("GOLDEN_KEEP=%d PRIS_KEEP=%d PAT_KEEP=%d" % (len(g), len(a), len(b)))
    print("TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG(golden keeps, we fold)=%d "
          "OURS-ONLY(we keep, golden folds)=%d"
          % (len(to_golden), len(away_golden), len(still_wrong),
             len(ours_only_pre)))
    for tag, rows in (("TO-GOLDEN", to_golden), ("AWAY-GOLDEN", away_golden),
                      ("STILL-WRONG", still_wrong),
                      ("OURS-ONLY", ours_only_pre)):
        for p in rows:
            print("  %-12s %s" % (tag, " | ".join(p)))
    return 1 if away_golden else 0


sys.exit(main())
