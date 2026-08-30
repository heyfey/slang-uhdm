#!/usr/bin/env python3
"""r10v164 -- the MULTISET check that score164.py's SET keys cannot make.

RESUME.md S9: "Multiset joins (keys collide; a last-writer dict drops rows)."
score164.py stores each key's values in a SET, so a key that occurs THREE times
in an elaborated view (three module instances) with golden 1 BARE + 2 BOUND and
ours 2 BARE + 1 BOUND scores IDENTICAL.  This tool counts (key, value) pairs as
a MULTISET and reports every count mismatch.

usage: v164_multiset.py <cen.g.txt> <cen.pris.txt> <cen.pat.txt> [FAM]
"""
import sys, collections

g, p, q = sys.argv[1], sys.argv[2], sys.argv[3]
fam = sys.argv[4] if len(sys.argv) > 4 else "CAS"


def load(path):
    c = collections.Counter()
    for line in open(path):
        line = line.rstrip("\n")
        if not line.startswith(fam + "|"):
            continue
        parts = line.split("|")
        view = parts[1].split(".")[-1]
        c[(view,) + tuple(parts[2:])] += 1
    return c


G, P, Q = load(g), load(p), load(q)
for lab, O in (("PRISTINE", P), ("PATCHED ", Q)):
    keys = set(G) | set(O)
    bad = [k for k in keys if G[k] != O[k]]
    tot = sum(abs(G[k] - O[k]) for k in bad)
    print(f"{lab} vs GOLDEN multiset: mismatched (key,value) pairs={len(bad)} count-delta={tot}")
moved = [k for k in set(P) | set(Q) if P[k] != Q[k]]
print(f"MOVED multiset pairs pris->pat: {len(moved)}")
away = 0
for k in sorted(moved):
    # AWAY = a pair patched has FEWER of, where golden's count matched pristine
    if P[k] == G[k] and Q[k] != G[k]:
        away += 1
        print("  AWAY-MULTISET", k, "G=", G[k], "pris=", P[k], "pat=", Q[k])
print(f"AWAY-MULTISET total: {away}")
