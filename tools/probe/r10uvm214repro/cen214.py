#!/usr/bin/env python3
"""r10uvm214 — the package-parameter BINDING census: a MULTISET join of
`ct214bind --keycount` rows.  MEASUREMENT ONLY; the official uhdm-cmp is the
sole acceptance judge.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

Row key = `ref|<name>|<line:col>` TAB `ACT=<kind>@<line:col>[<listing>]{...}`
TAB `<holder chain>`, with a COUNT.  The bound object's OWN LISTING is in the
payload on purpose: when a def-view Rhs and its elaborated twin carry the same
value the judge cannot tell them apart, but the BYTES can, and this pass has to
predict every byte mover by name.  The join is a MULTISET join (counts
subtract), never a dict overwrite — RESUME §9's census trap.

usage: cen214.py <golden.keycount> <ours.keycount> [--only-substr S]
prints ONLY-GOLDEN / ONLY-OURS rows and the totals.
"""
import sys
from collections import Counter


def load(path, only):
    c = Counter()
    with open(path) as f:
        for line in f:
            if not line.startswith("KC\t"):
                continue
            parts = line.rstrip("\n").split("\t")
            if len(parts) != 5:
                continue
            _, key, pay, holder, n = parts
            if only and only not in holder and only not in key:
                continue
            c[(key, pay, holder)] += int(n)
    return c


def main():
    g, o = sys.argv[1], sys.argv[2]
    only = None
    if "--only-substr" in sys.argv:
        only = sys.argv[sys.argv.index("--only-substr") + 1]
    G, O = load(g, only), load(o, only)
    og = G - O
    oo = O - G
    for k in sorted(og):
        print("ONLY-GOLDEN\t%d\t%s\t%s\t%s" % (og[k], k[0], k[1], k[2]))
    for k in sorted(oo):
        print("ONLY-OURS\t%d\t%s\t%s\t%s" % (oo[k], k[0], k[1], k[2]))
    print("-- CENSUS golden=%d ours=%d AGREE=%d ONLY-GOLDEN=%d ONLY-OURS=%d"
          % (sum(G.values()), sum(O.values()),
             sum((G & O).values()), sum(og.values()), sum(oo.values())))


if __name__ == "__main__":
    main()
