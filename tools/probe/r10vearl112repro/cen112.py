#!/usr/bin/env python3
"""r10earl112 -- the MULTISET join and scorer for cen111's census.

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
LHS is ALWAYS golden; RHS is ALWAYS ours.

RESUME.md section 9: "Multiset joins (keys collide; a last-writer dict drops
rows)" and "NODEDUP censuses manufacture AWAY-GOLDEN phantoms".  So every side
is read as key -> Counter(payload), the join is per-key over the payload
multiset, and a key present on only one side is reported in its OWN bucket and
never scored as a move.

  usage: cen112.py <golden.txt> <pristine.txt> [<patched.txt>]

Two-file mode scores PRISTINE against golden.  Three-file mode scores the MOVE:
    TOGOLD      pristine != golden, patched == golden        (a win)
    AWAY        pristine == golden, patched != golden        (a LOSS -- must be 0)
    MOVEDWRONG  pristine != golden, patched != golden, moved (a LOSS -- must be 0)
    STILLWRONG  pristine != golden, patched == pristine      (untouched residue)
    SAME_AGREE  pristine == golden == patched
"""
import sys
from collections import Counter, defaultdict


def load(p):
    d = defaultdict(Counter)
    rc = None
    n = 0
    with open(p) as f:
        for line in f:
            line = line.rstrip("\n")
            if line.startswith("CENRC "):
                rc = int(line.split()[1])
                continue
            parts = line.split("\t")
            if len(parts) < 3:
                continue
            # parts[3], when present, is the DIAGNOSTIC file column -- never
            # part of the key and never part of the payload.
            d[parts[0]][parts[1]] += int(parts[2])
            n += 1
    if rc != 0:
        sys.exit("FATAL: %s did not end CENRC 0 (rc=%s)" % (p, rc))
    return d, n


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    g, ng = load(sys.argv[1])
    a, na = load(sys.argv[2])
    b = None
    if len(sys.argv) > 3:
        b, nb = load(sys.argv[3])

    keys = set(g) | set(a) | (set(b) if b else set())
    gonly = [k for k in keys if k in g and k not in a and (b is None or k not in b)]
    oonly = [k for k in keys if k not in g and (k in a or (b and k in b))]
    both = sorted(k for k in keys if k in g and (k in a or (b and k in b)))

    if b is None:
        same = diff = 0
        for k in both:
            if g[k] == a[k]:
                same += 1
            else:
                diff += 1
        print("MODE 2-file (pristine vs golden)")
        print("keys golden=%d ours=%d joined=%d" % (len(g), len(a), len(both)))
        print("SAME %d   DIFF %d   G-ONLY %d   O-ONLY %d" %
              (same, diff, len(gonly), len(oonly)))
        for k in both:
            if g[k] != a[k]:
                print("DIFF\t%s\n\tG %s\n\tO %s" % (k, dict(g[k]), dict(a[k])))
        return

    togold = away = movedwrong = stillwrong = same_agree = 0
    # The SHAPE score.  A key whose payload SET already matched golden but
    # whose MULTIPLICITY did not (an arena copy count -- the def/elab views put
    # 8 copies of a select where golden puts 4) is a PRE-EXISTING count residue
    # that no generated Compare can read: `expr::Compare` reads the constant's
    # Typespec, never how many arena copies of the constant exist.  Scoring
    # such a key MOVEDWRONG on the strict multiset would report a loss where
    # the official uhdm-cmp reports EQUAL (g6_view111_elab: strict MOVEDWRONG
    # 1, official cmp 17 lines -> 0, EQUAL).  So both scores are printed, the
    # strict one first, and the SHAPE line is the one the law is judged on --
    # with COUNT-ONLY broken out so nothing is hidden.
    sh_togold = sh_away = sh_moved = sh_still = sh_same = sh_count = 0
    setof = lambda c: frozenset(c)
    for k in both:
        G, A, B = g.get(k, Counter()), a.get(k, Counter()), b.get(k, Counter())
        if A == G and B == G:
            same_agree += 1
        elif A != G and B == G:
            togold += 1
            print("TOGOLD\t%s\n\tG %s\n\tP %s" % (k, dict(G), dict(A)))
        elif A == G and B != G:
            away += 1
            print("AWAY\t%s\n\tG %s\n\tPATCHED %s" % (k, dict(G), dict(B)))
        elif A != G and B != G and A != B:
            movedwrong += 1
            print("MOVEDWRONG\t%s\n\tG %s\n\tP %s\n\tPATCHED %s" %
                  (k, dict(G), dict(A), dict(B)))
        else:
            stillwrong += 1
        sG, sA, sB = setof(G), setof(A), setof(B)
        if sA == sG and sB == sG:
            sh_same += 1
            if A != G or B != G:
                sh_count += 1
        elif sA != sG and sB == sG:
            sh_togold += 1
        elif sA == sG and sB != sG:
            sh_away += 1
            print("SHAPE-AWAY\t%s\n\tG %s\n\tPATCHED %s" % (k, dict(G), dict(B)))
        elif sA != sB:
            sh_moved += 1
            print("SHAPE-MOVEDWRONG\t%s\n\tG %s\n\tP %s\n\tPATCHED %s" %
                  (k, dict(G), dict(A), dict(B)))
        else:
            sh_still += 1
    print("MODE 3-file (golden / pristine / patched)")
    print("keys golden=%d pristine=%d patched=%d joined=%d" %
          (len(g), len(a), len(b), len(both)))
    print("STRICT TOGOLD %d  AWAY %d  MOVEDWRONG %d  STILLWRONG %d  "
          "SAME_AGREE %d  G-ONLY %d  O-ONLY %d" %
          (togold, away, movedwrong, stillwrong, same_agree, len(gonly),
           len(oonly)))
    print("SHAPE  TOGOLD %d  AWAY %d  MOVEDWRONG %d  STILLWRONG %d  "
          "SAME_AGREE %d  (of which COUNT-ONLY %d)" %
          (sh_togold, sh_away, sh_moved, sh_still, sh_same, sh_count))
    # A one-sided set that CHANGED between pristine and patched is a move too.
    ch = [k for k in (set(a) | set(b)) - set(g) if a.get(k) != b.get(k)]
    print("ONE-SIDED-CHANGED %d" % len(ch))
    for k in ch:
        print("ONESIDED\t%s\n\tP %s\n\tPATCHED %s" %
              (k, dict(a.get(k, Counter())), dict(b.get(k, Counter()))))


main()
