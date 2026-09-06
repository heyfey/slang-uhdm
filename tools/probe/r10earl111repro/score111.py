#!/usr/bin/env python3
"""r10earl111 -- the CORPUS scorer for censweep111's rows.

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
LHS is ALWAYS golden; RHS is ALWAYS ours.

  usage: score111.py <rows.tsv> [<patched_rows.tsv>]

rows.tsv columns: side(G|O) \t row \t key \t payload \t count \t files

The join is a MULTISET join per (row, key) over the payload multiset -- never a
last-writer dict (RESUME.md section 9).  Keys present on one side only are
reported in their own bucket and never scored as a move.

TWO buckets are reported separately, because they answer different questions:
  EDGE      the BARE-vs-stamped shape of the typespec edge -- what this pass's
            law changes.  This is the column that must go to zero.
  PAYLOAD   the same edge shape on both sides but a different Compare-visible
            typespec payload.
  COUNT     identical payload SETS, different multiplicities -- a pre-existing
            def/elab copy-count difference this law does not touch.

With a second file the move is scored TOGOLD / AWAY / MOVEDWRONG / STILLWRONG,
where AWAY is `pristine agreed with golden and the patch broke it` -- the
column that must read 0.
"""
import sys
from collections import Counter, defaultdict


def load(p):
    d = defaultdict(Counter)
    files = {}
    with open(p) as f:
        for line in f:
            c = line.rstrip("\n").split("\t")
            if len(c) < 5:
                continue
            d[(c[0], c[1], c[2])][c[3]] += int(c[4])
            if len(c) > 5:
                files[(c[1], c[2])] = c[5]
    return d, files


def shape(counter):
    return frozenset("TS" if k != "BARE" else "BARE" for k in counter)


def sides(d):
    g = {k[1:]: v for k, v in d.items() if k[0] == "G"}
    o = {k[1:]: v for k, v in d.items() if k[0] == "O"}
    return g, o


def classify(g, o):
    """-> dict bucket -> list of (row, key)"""
    out = defaultdict(list)
    for k in set(g) & set(o):
        if g[k] == o[k]:
            continue
        if shape(g[k]) != shape(o[k]):
            out["EDGE"].append(k)
        elif set(g[k]) != set(o[k]):
            out["PAYLOAD"].append(k)
        else:
            out["COUNT"].append(k)
    for k in set(g) - set(o):
        out["G-ONLY"].append(k)
    for k in set(o) - set(g):
        out["O-ONLY"].append(k)
    return out


def main():
    d, files = load(sys.argv[1])
    g, o = sides(d)
    b1 = classify(g, o)
    joined = len(set(g) & set(o))
    if len(sys.argv) < 3:
        print("MODE 2-file (pristine vs golden)")
        print("pairs golden=%d ours=%d joined=%d" % (len(g), len(o), joined))
        print("EDGE %d  PAYLOAD %d  COUNT %d  G-ONLY %d  O-ONLY %d" %
              (len(b1["EDGE"]), len(b1["PAYLOAD"]), len(b1["COUNT"]),
               len(b1["G-ONLY"]), len(b1["O-ONLY"])))
        print("\n--- EVERY EDGE cell (golden vs ours) ---")
        for k in sorted(b1["EDGE"]):
            print("%s\n\t%s\n\tG %s\n\tO %s" %
                  (k[0], k[1], dict(g[k]), dict(o[k])))
        return

    d2, files2 = load(sys.argv[2])
    g2, o2 = sides(d2)
    # golden must be IDENTICAL between the two sweeps -- if it is not, the
    # sweeps did not read the same goldens and nothing below is comparable.
    if g != g2:
        only = set(g) ^ set(g2)
        print("FATAL: golden side differs between the two sweeps (%d keys)" %
              len(only))
        sys.exit(4)
    togold = away = movedwrong = stillwrong = same = 0
    lines = []
    for k in sorted(set(g) & (set(o) | set(o2))):
        G, A, B = g.get(k, Counter()), o.get(k, Counter()), o2.get(k, Counter())
        if A == G and B == G:
            same += 1
        elif A != G and B == G:
            togold += 1
            lines.append("TOGOLD\t%s\t%s\n\tG %s\n\tP %s" % (k[0], k[1], dict(G), dict(A)))
        elif A == G and B != G:
            away += 1
            lines.append("AWAY\t%s\t%s\n\tG %s\n\tPATCHED %s" % (k[0], k[1], dict(G), dict(B)))
        elif A != B:
            movedwrong += 1
            lines.append("MOVEDWRONG\t%s\t%s\n\tG %s\n\tP %s\n\tPATCHED %s" %
                         (k[0], k[1], dict(G), dict(A), dict(B)))
        else:
            stillwrong += 1
    onesided = [k for k in (set(o) | set(o2)) - set(g)
                if o.get(k) != o2.get(k)]
    print("MODE 3-file (golden / pristine / patched)")
    print("pairs golden=%d pristine=%d patched=%d" % (len(g), len(o), len(o2)))
    print("TOGOLD %d  AWAY %d  MOVEDWRONG %d  STILLWRONG %d  SAME_AGREE %d  "
          "ONE-SIDED-CHANGED %d" %
          (togold, away, movedwrong, stillwrong, same, len(onesided)))
    for l in lines:
        print(l)
    for k in sorted(onesided):
        print("ONESIDED\t%s\t%s\n\tP %s\n\tPATCHED %s" %
              (k[0], k[1], dict(o.get(k, Counter())), dict(o2.get(k, Counter()))))


main()
