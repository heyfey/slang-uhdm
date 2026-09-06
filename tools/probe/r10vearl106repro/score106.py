#!/usr/bin/env python3
"""r10earl106 THREE-WAY SCORER -- MEASUREMENT ONLY.

  score106.py <pristine cenrun106 tsv> <patched cenrun106 tsv> [--judge]

Joins two `cenrun106.sh` outputs on the full CELL key
(corpus-mode|test  +  view|home|ca-fullname|ca-span|ca-ordinal|depth|#idx) so
the four outcomes a two-way diff conflates are separated.  The GOLDEN side is
ASSERTED byte-unchanged between the two runs FIRST: if a single cell's golden
payload differs the score is meaningless and the script says so and stops
(r10earl104's rule, kept).

  TO-GOLDEN     pristine != golden, patched == golden      (the law's gain)
  AWAY-GOLDEN   pristine == golden, patched != golden      (THE ONLY REGRESSION
                                                            CLASS -- printed
                                                            first, in full)
  MOVED-WRONG   changed, still != golden                   (one wrong answer
                                                            swapped for another)
  UNMOVED-GOOD  unchanged and == golden
  UNMOVED-BAD   unchanged and != golden                    (a named residue)
  UNREACHABLE   a key the GOLDEN side does not hold at all: the parent kinds
                already differ there, so `Compare` stops ABOVE the node on both
                binaries and nothing under it is read.  Split into UNREACHABLE
                (we did not move it) and UNREACHABLE-CHANGED (we did, and the
                judge cannot see it) -- r10earl104's `[RHS-KIND-DIFFERS]` rule
                applied at node granularity.
  ADDED/REMOVED a key only one binary produces

PAYLOADS.  uvm159's lesson: score the STRING, never a count.
  default   the FULL node: kind, and for a constant its VpiSize / VpiConstType
            / VpiValue / VpiDecompile plus the typespec rendered verbatim; for
            a ref_obj its VpiName and the KIND of its Actual_group.
  --judge   the same pair PROJECTED onto what the official Compare reads:
            `constant::Compare` reads VpiSize / VpiConstType / VpiDecompile /
            VpiValue and the Typespec; `int_typespec::Compare` reads VpiType /
            VpiName / VpiDefName / VpiSigned / Ranges and NEVER VpiValue;
            `typespec::Compare` never reads VpiFile or the span; and
            `ref_obj::Compare` DOES read Actual_group.  So a typespec's
            LOCATION and its minted VpiValue are dump-visible and cmp-invisible.
"""
import sys
from collections import defaultdict


def project_ts(ts):
    """Keep only the typespec fields the generated Compare reads."""
    t = ts.split("@")[0]
    for part in ts.split(",")[1:]:
        if part.startswith(("name=", "def=", "ranges=")) or part == "signed":
            t += "," + part
    return t


def project(payload):
    """Project a whole node payload onto the judge's read fields."""
    # r10earl106: drop the trailing LOC=/LOCLESS column first -- verified in
    # ~/git-repos/UHDM/build/generated/src/{BaseClass,expr,constant}.cpp that no
    # Compare on this pass's path reads a location.
    for sep in ("  LOCLESS", "  LOC="):
        j = payload.find(sep)
        if j >= 0:
            payload = payload[:j]
            break
    i = payload.find(",TS=")
    if i < 0:
        return payload
    return payload[:i] + ",TS=" + project_ts(payload[i + 4:])


def load(path):
    """key -> (golden payload, ours payload); ONLY-* rows carry a sentinel."""
    out = {}
    dup = 0
    with open(path) as fh:
        for line in fh:
            f = line.rstrip("\n").split("\t")
            if len(f) < 3:
                continue
            pre, kind = f[0], f[1]
            # cen106 row shapes (the ORG and LOC columns are r10earl106's):
            #   pre CELL SAME/DIFF key ORG <org> G <g> <gloc> O <o> <oloc>
            #   pre ONLY-GOLDEN key ORG <org> <g> <gloc>
            #   pre ONLY-OURS   key ORG <org> <o> <oloc>
            # The LOCATION rides in the DEFAULT payload (so the pass is scored
            # on the whole object) and is PROJECTED AWAY by --judge, because no
            # generated Compare reads VpiFile / VpiLineNo / VpiColumnNo.
            if kind == "CELL" and len(f) >= 12:
                key = pre + "\t" + f[3]
                g, o = f[7] + "  " + f[8], f[10] + "  " + f[11]
            elif kind == "ONLY-GOLDEN" and len(f) >= 7:
                key = pre + "\t" + f[2]
                g, o = f[5] + "  " + f[6], "<ABSENT-OURS>"
            elif kind == "ONLY-OURS" and len(f) >= 7:
                key = pre + "\t" + f[2]
                g, o = "<ABSENT-GOLDEN>", f[5] + "  " + f[6]
            else:
                continue
            if key in out:
                dup += 1
            out[key] = (g, o)
    return out, dup


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    judge = "--judge" in sys.argv
    P, dupP = load(args[0])
    A, dupA = load(args[1])
    print("# pristine cells=%d (dupkeys %d)  patched cells=%d (dupkeys %d)"
          % (len(P), dupP, len(A), dupA))

    # GOLDEN-SIDE ASSERTION FIRST.
    bad = 0
    for k in set(P) & set(A):
        if P[k][0] != A[k][0]:
            bad += 1
            if bad <= 5:
                print("GOLDEN-MOVED\t%s\n   pristine-run %s\n   patched-run  %s"
                      % (k, P[k][0], A[k][0]))
    if bad:
        print("REFUSING TO SCORE: the GOLDEN side differs on %d cells." % bad)
        return 2
    print("GOLDEN-SIDE-IDENTICAL on %d shared cells" % len(set(P) & set(A)))

    tally = defaultdict(int)
    fams = defaultdict(int)
    away, wrong, togold, unreach = [], [], [], []
    for k in set(P) | set(A):
        if k not in A:
            tally["REMOVED"] += 1
            continue
        if k not in P:
            tally["ADDED"] += 1
            continue
        g, po = P[k]
        _, ao = A[k]
        if judge:
            g, po, ao = project(g), project(po), project(ao)
        # A key the GOLDEN side does not hold at all is UNREACHABLE to the
        # judge: the parent kinds already differ there (golden folded the
        # whole subtree, or we did), so `Compare` stops above it on BOTH
        # binaries and nothing under it is read.  r10earl104's
        # `[RHS-KIND-DIFFERS]` rule, applied at node granularity.
        if g in ("<ABSENT-GOLDEN>",) or po == "<ABSENT-OURS>":
            tally["UNREACHABLE-CHANGED" if po != ao else "UNREACHABLE"] += 1
            if po != ao:
                unreach.append((k, po, ao))
            continue
        pg, ag = (po == g), (ao == g)
        if po == ao:
            tally["UNMOVED-GOOD" if ag else "UNMOVED-BAD"] += 1
        elif ag:
            tally["TO-GOLDEN"] += 1
            togold.append((k, g, po))
            fams["TO-GOLDEN\t%s  >  %s" % (po, ao)] += 1
        elif pg:
            tally["AWAY-GOLDEN"] += 1
            away.append((k, g, po, ao))
        else:
            tally["MOVED-WRONG"] += 1
            wrong.append((k, g, po, ao))
            fams["MOVED-WRONG\t%s  >  %s  (golden %s)" % (po, ao, g)] += 1

    print("\n== AWAY-GOLDEN (the only regression class): %d" % tally["AWAY-GOLDEN"])
    for k, g, po, ao in away:
        print("AWAY\t%s\n   golden   %s\n   pristine %s\n   patched  %s"
              % (k, g, po, ao))
    print("\n== MOVED-WRONG: %d" % tally["MOVED-WRONG"])
    for k, g, po, ao in wrong[:40]:
        print("WRONG\t%s\n   golden   %s\n   pristine %s\n   patched  %s"
              % (k, g, po, ao))
    print("\n== UNREACHABLE-CHANGED (golden holds no node at this key -- the "
          "judge stops above it on both binaries): %d"
          % tally["UNREACHABLE-CHANGED"])
    for k, po, ao in unreach[:20]:
        print("UNREACH\t%s\n   pristine %s\n   patched  %s" % (k, po, ao))
    print("\n== SCORE%s" % (" (--judge projection)" if judge else ""))
    for kk in ("AWAY-GOLDEN", "MOVED-WRONG", "TO-GOLDEN", "UNMOVED-GOOD",
               "UNMOVED-BAD", "UNREACHABLE", "UNREACHABLE-CHANGED",
               "ADDED", "REMOVED"):
        print("  %-13s %7d" % (kk, tally[kk]))
    print("\n== FAMILIES")
    for f, c in sorted(fams.items(), key=lambda x: -x[1]):
        print("FAM\t%6d\t%s" % (c, f))
    return 0


if __name__ == "__main__":
    sys.exit(main())
