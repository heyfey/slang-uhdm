#!/usr/bin/env python3
"""r10earl104 THREE-WAY SCORER -- MEASUREMENT ONLY.

  score104.py <pristine cen104 --all> <patched cen104 --all> [--prefixed]
                                                             [--judge] [--ts]

Joins two `cen104 --all` runs on the CELL key (view|Lhs-fullname|span) so the
four outcomes a two-way diff conflates are separated.  The GOLDEN side is
ASSERTED byte-unchanged between the two runs FIRST: if a single cell's golden
payload differs the score is meaningless and the script says so and stops.

  TO-GOLDEN     pristine != golden, patched == golden      (the law's gain)
  AWAY-GOLDEN   pristine == golden, patched != golden      (THE ONLY REGRESSION
                                                            CLASS -- tallied and
                                                            printed first)
  MOVED-WRONG   changed, still != golden                   (one wrong answer
                                                            swapped for another)
  UNMOVED-GOOD  unchanged and == golden
  UNMOVED-BAD   unchanged and != golden                    (a named residue)
  ADDED/REMOVED a key only one binary produces

PAYLOADS -- three, because they answer three different questions and mixing
them is how a pass reports a regression it does not have (or misses one it
does).  uvm159's verifier lesson applies to all three: score the STRING, never
a count.
  default   the FULL cell: the Rhs constant's encoding AND the typespec
            rendered verbatim (kind, span-or-loclessness, name, signedness,
            VpiValue, every range bound).  The dump-truth.
  --judge   the same pair PROJECTED onto what the official Compare reads.
            `int_typespec::Compare` reads VpiType / VpiName / VpiDefName /
            Typedef_alias / Instance / Cast_to_expr / VpiSigned / Ranges and
            NEVER VpiValue; `typespec::Compare` never reads VpiFile or the
            span.  So a minted VpiValue and a location are dump-visible and
            cmp-invisible.
  --ts      the TYPESPEC COLUMN ALONE (add --judge for its read fields), with
            RHS-KIND-DIFFERS printed beside every moved cell: when the two
            sides' Rhs kinds already disagree, `param_assign::Compare` stops at
            the Rhs's VpiType and the typespec underneath is UNREACHABLE to the
            judge on both binaries.
"""
import sys
from collections import defaultdict


def project(ts):
    """Keep only the typespec fields the generated Compare reads."""
    t = ts.split("@")[0]
    for part in ts.split(",")[1:]:
        if part.startswith(("name=", "def=", "ranges=")) or part == "signed":
            t += "," + part
    return t


def load(path, prefixed):
    cells = {}
    for line in open(path, encoding="utf-8", errors="replace"):
        f = line.rstrip("\n").split("\t")
        off = 1 if prefixed else 0
        if len(f) < off + 11 or f[off] != "CELL":
            continue
        key = (f[0] + "\t" if prefixed else "") + f[off + 2] + "\t" + f[off + 3]
        cells[key] = (f[off + 5], f[off + 6], f[off + 8], f[off + 9])
    return cells


def main():
    if len(sys.argv) < 3:
        sys.exit("usage: score104.py <pristine> <patched> "
                 "[--prefixed] [--judge] [--ts]")
    flags = sys.argv[3:]
    prefixed, judged, tsonly = ("--prefixed" in flags, "--judge" in flags,
                                "--ts" in flags)
    P, Q = load(sys.argv[1], prefixed), load(sys.argv[2], prefixed)

    def payload(c, side):
        rhs, ts = (c[0], c[1]) if side == "g" else (c[2], c[3])
        if judged:
            ts = project(ts)
        return ts if tsonly else rhs + "\t" + ts

    print("PAYLOAD %s%s" % ("TYPESPEC-ONLY" if tsonly else "RHS+TYPESPEC",
                            " JUDGE-VISIBLE-FIELDS" if judged else " FULL-STRING"))
    gdiff = [k for k in P if k in Q and payload(P[k], "g") != payload(Q[k], "g")]
    if gdiff:
        print("GOLDEN-SIDE-CHANGED %d cells -- THE SCORE IS MEANINGLESS" % len(gdiff))
        for k in gdiff[:10]:
            print("   ", k, "\n     pris", payload(P[k], "g"),
                  "\n     patc", payload(Q[k], "g"))
        return 2
    print("GOLDEN-SIDE-IDENTICAL over %d shared keys" % len(set(P) & set(Q)))

    tally = defaultdict(int)
    rows = defaultdict(list)
    for k in sorted(set(P) | set(Q)):
        if k not in Q:
            tally["REMOVED"] += 1
            continue
        if k not in P:
            tally["ADDED"] += 1
            continue
        g, po, qo = payload(P[k], "g"), payload(P[k], "o"), payload(Q[k], "o")
        # Is the typespec underneath even REACHABLE to the judge?  It is not
        # when the two sides' Rhs kinds already disagree.
        reach = P[k][0].split(",")[0] == P[k][2].split(",")[0]
        pg, qg = (po == g), (qo == g)
        if po == qo:
            name = "UNMOVED-GOOD" if pg else "UNMOVED-BAD"
        elif qg:
            name = "TO-GOLDEN"
        elif pg:
            name = "AWAY-GOLDEN"
        else:
            name = "MOVED-WRONG"
        tally[name] += 1
        if name in ("AWAY-GOLDEN", "MOVED-WRONG", "TO-GOLDEN"):
            rows[name].append((k, g, po, qo, reach))

    for name in ("AWAY-GOLDEN", "MOVED-WRONG", "TO-GOLDEN", "UNMOVED-GOOD",
                 "UNMOVED-BAD", "ADDED", "REMOVED"):
        print("%-14s %6d" % (name, tally[name]))
    for name in ("AWAY-GOLDEN", "MOVED-WRONG", "TO-GOLDEN"):
        for k, g, po, qo, reach in rows[name]:
            print("%s %s%s\n    G    %s\n    pris %s\n    patc %s"
                  % (name, k, "" if reach else "  [RHS-KIND-DIFFERS: the judge "
                     "stops at the Rhs, this typespec is UNREACHABLE]",
                     g, po, qo))
    return 0


if __name__ == "__main__":
    sys.exit(main())
