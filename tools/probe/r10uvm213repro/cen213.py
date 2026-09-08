#!/usr/bin/env python3
"""r10uvm213 — the placeholder-copy census: a MULTISET join of `ct213ts
--keycount` rows.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

Row key = `<typespec kind>|<name>|<line:col>` TAB `<Instance VIEW>` TAB
`<holder chain>`, with a COUNT.  The DEF/ELAB view is IN the key on purpose:
which view a placeholder's back-pointer names is the whole question, and both
producers label the two package listings the same way (design->AllPackages /
TopPackages).  The join is a MULTISET join (counts subtract), never a dict
overwrite — RESUME §9's census trap.

usage: cen213.py <golden.keycount> <ours.keycount> [--only-substr S]
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
            _, key, view, holder, n = line.rstrip("\n").split("\t")
            if only and only not in holder and only not in key:
                continue
            c[(key, view, holder)] += int(n)
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
