#!/usr/bin/env python3
"""r10uvm181 - the three-way arm scorer, MULTISET form.

Joins one arm's GOLDEN, PRISTINE and PATCHED cell dumps (ct181grid output, one
line per reference: <tag>\\t<key>\\t<value>) and reports the only verdicts that
matter for a landing:

  TOGOLD       pristine disagreed with golden, patched agrees      (the law)
  AWAY         pristine agreed with golden, patched does not       (must be 0)
  MOVED-WRONG  patched changed the cell to a THIRD value           (must be 0)
  STILL-WRONG  both disagree with golden, unchanged                (a residue)
  AGREE-BOTH   both agree with golden                              (the floor)

WHY A MULTISET AND NOT A PER-OCCURRENCE RANK: r10uvm180's scorer keyed each
occurrence by its rank at the face, which silently MIS-PAIRS the moment the two
sides hold different NUMBERS of objects at one face - and they do: our clone
emits one more `ref_var` at a foreach loop variable's declaration site than
golden does (the pass-37 shared object plus the listing entry, plus a third we
mint), so `#1` on the left and `#1` on the right were different objects and a
cell that moved cleanly to golden scored KEY-GAP / NO-GOLDEN instead.  Grouping
every occurrence of a face into a SORTED MULTISET and comparing the multisets
removes the ordering assumption entirely, at the price of reporting a
cardinality difference as STILL-WRONG - which is the honest verdict for it, and
which the CARD line counts separately so it can never be read as a movement.

Keys present on only one side are reported and never scored: a key gap is a
pairing problem, not a movement, and counting one as a movement is how a NODEDUP
census manufactures AWAY-GOLDEN phantoms (RESUME.md section 9).

usage: score181.py <cen.g.txt> <cen.a.txt> <cen.b.txt> [label] [--quiet]
"""
import sys
from collections import defaultdict


def load(path):
    d = defaultdict(list)
    with open(path) as f:
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 3:
                continue
            key = parts[1]
            # strip a trailing "#<rank>" if the dumper emitted one
            if "#" in key:
                key = key.rsplit("#", 1)[0]
            d[key].append(parts[2])
    return {k: tuple(sorted(v)) for k, v in d.items()}


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        return 2
    G, A, B = (load(p) for p in sys.argv[1:4])
    label = sys.argv[4] if len(sys.argv) > 4 else "arm"
    quiet = "--quiet" in sys.argv[4:]
    keys = set(G) | set(A) | set(B)
    togold = away = movedwrong = stillwrong = agreeboth = 0
    onlyg = onlya = onlyb = card = 0
    # PER-OCCURRENCE agreement, the sharp regression measure.  A whole-cell
    # verdict cannot tell a cell that went RIGHT->WRONG from one that was never
    # right and merely changed its wrong answer: `shadow181_fn`'s nested
    # foreach re-using the enclosing loop variable's NAME is the second kind
    # (golden binds the INNER declaration, we re-list the OUTER object in both
    # binaries).  `regress` counts only cells where FEWER occurrences agree
    # with golden after than before, and it is the number that must be 0.
    right_before = right_after = regress = gained = 0
    lines = []
    def agree(x, g):
        gg = list(g)
        n = 0
        for v in x:
            if v in gg:
                gg.remove(v)
                n += 1
        return n
    for k in sorted(keys):
        g, a, b = G.get(k), A.get(k), B.get(k)
        if g is None:
            onlyg += 1
            lines.append("NO-GOLDEN   %s  pris=%s  pat=%s" % (k, a, b))
            continue
        if a is None or b is None:
            if a is None:
                onlya += 1
            if b is None:
                onlyb += 1
            lines.append("KEY-GAP     %s  gold=%s pris=%s pat=%s" % (k, g, a, b))
            continue
        if len(a) != len(g) or len(b) != len(g):
            card += 1
        ra, rb = agree(a, g), agree(b, g)
        right_before += ra
        right_after += rb
        if rb < ra:
            regress += 1
            lines.append("REGRESSION  %s  gold=%s  right %d -> %d" % (k, g, ra, rb))
        elif rb > ra:
            gained += 1
        if a == g and b == g:
            agreeboth += 1
        elif a != g and b == g:
            togold += 1
            lines.append("TOGOLD      %s  gold=%s  was=%s" % (k, g, a))
        elif a == g and b != g:
            away += 1
            lines.append("AWAY        %s  gold=%s  now=%s" % (k, g, b))
        elif a != g and b != g and a != b:
            movedwrong += 1
            lines.append("MOVED-WRONG %s  gold=%s  was=%s  now=%s" % (k, g, a, b))
        else:
            stillwrong += 1
            lines.append("STILL-WRONG %s  gold=%s  both=%s" % (k, g, a))
    if not quiet:
        for l in lines:
            print(l)
    print("SCORE %s TOGOLD=%d AWAY=%d MOVED-WRONG=%d STILL-WRONG=%d "
          "AGREE-BOTH=%d CARD-DIFF=%d ONLY-GOLDEN=%d KEY-GAP-pris=%d "
          "KEY-GAP-pat=%d faces=%d | OCCURRENCES right %d -> %d "
          "REGRESSION-CELLS=%d GAIN-CELLS=%d"
          % (label, togold, away, movedwrong, stillwrong, agreeboth, card,
             onlyg, onlya, onlyb, len(keys), right_before, right_after,
             regress, gained))
    return 0


if __name__ == "__main__":
    sys.exit(main())
