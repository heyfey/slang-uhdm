#!/usr/bin/env python3
"""r10uvm219 — the ORDER-ONLY scorer.  MEASUREMENT ONLY; the official uhdm-cmp
is the sole judge.  LHS is ALWAYS golden, RHS is ALWAYS ours.

WHY THIS EXISTS.  A position-keyed census (cen219.py) is the right scorer for a
listing whose ARITY already matches, but it cannot read the ORDER of a listing
that is missing an element: one hole shifts every later position, so a listing
whose surviving elements are in golden's exact order scores WORSE than one that
is out of order but happens to realign after the hole.  Grid arm G is that
case — r10uvm217's R2 leaves one forwarded wire unminted on BOTH binaries — so
the arm needs a measure that is blind to the hole and sensitive only to ORDER.

THE MEASURE.  For each listing cell (`<view>|<inst key>|nets`/`vars`) it asks
whether OUR name sequence is a SUBSEQUENCE of golden's — i.e. every element we
emit appears in golden in the same relative order — and, symmetrically, whether
golden's is a subsequence of ours.  SUB-OK means "we emit no pair of elements in
the wrong relative order".  It says nothing about what is missing; that is
cen219.py's ONLY-GOLDEN / BAG-ONLY-GOLDEN column, which this tool does not
replace.

Usage: subseq219.py <golden.cen> <ours.cen>
Exit status is always 0; the last line is the machine-readable summary.
"""
import sys


def load(path):
    cells = {}
    order = []
    for line in open(path):
        line = line.rstrip("\n")
        f = line.split("|")
        if not f:
            continue
        if f[0] == "ARITY":
            key = "|".join(f[1:4])
            if key not in cells:
                cells[key] = []
                order.append(key)
        elif f[0] in ("NET", "VAR"):
            kind = "nets" if f[0] == "NET" else "vars"
            key = "|".join([f[1], f[2], kind])
            cells.setdefault(key, [])
            if key not in order:
                order.append(key)
            cells[key].append(f[5])
    return cells, order


def is_sub(a, b):
    """a is a subsequence of b"""
    it = iter(b)
    return all(x in it for x in a)


def main():
    g, gorder = load(sys.argv[1])
    o, _ = load(sys.argv[2])
    keys = sorted(set(g) | set(o))
    tot = subok = subbad = both = 0
    for k in keys:
        gv = g.get(k, [])
        ov = o.get(k, [])
        if not gv and not ov:
            continue
        tot += 1
        ok = is_sub(ov, gv)
        rev = is_sub(gv, ov)
        if ok and rev:
            both += 1
        if ok:
            subok += 1
        else:
            subbad += 1
            print("ORDER-WRONG|%s|G=%s|O=%s" % (k, ",".join(gv), ",".join(ov)))
    print("-- CELLS=%d SUB-OK=%d ORDER-WRONG=%d IDENTICAL=%d"
          % (tot, subok, subbad, both))


main()
