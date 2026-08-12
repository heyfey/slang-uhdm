#!/usr/bin/env python3
"""szcmp60.py — SPAN-FREE per-owner proof for § tfBodyConstArgNoFormalTs60.

The per-shape attributor (mv60.sh) keys dump lines by their TEXT, and every dump
line naming a MACRO-EXPANDED constant carries a SPAN the two sides disagree on by
construction (golden puts uvm-1.2's `1` at 150:156, we put it at 149:331 — the
location residue this pass files as dump-only).  So no span-keyed instrument can
align those objects, and the size/typespec claim has to be proved as a MULTISET
over span-free CELLS instead:

    (scope, value-encoding prefix, vpiSize, vpiConstType, has-typespec)

Usage:  szcmp60.py <golden.cells> <pristine.cells> <patched.cells>
where each file is `argts60 <db> | grep '^CELL\tSIZECELL'` output.

Prints, for every cell whose count differs between ANY pair, golden / pristine /
patched; then the summed |golden - x| distance over ALL cells for pristine and
for patched.  A distance that DROPS is the claim; the per-cell table says where.
"""
import sys
from collections import Counter


def load(p):
    c = Counter()
    with open(p) as f:
        for line in f:
            parts = line.rstrip("\n").split("\t")
            # CELL SIZECELL scope prefix size ct ts count
            if len(parts) < 8 or parts[0] != "CELL" or parts[1] != "SIZECELL":
                continue
            key = tuple(parts[2:7])
            c[key] += int(parts[7])
    if not c:
        sys.exit("REFUSING TO REPORT: no SIZECELL rows in " + p)
    return c


g, o, n = (load(x) for x in sys.argv[1:4])
keys = sorted(set(g) | set(o) | set(n))
print(f"{'scope':<14}{'pfx':<8}{'size':<12}{'ct':<8}{'ts':<6}"
      f"{'GOLD':>7}{'PRIS':>7}{'PAT':>7}")
for k in keys:
    if g[k] == o[k] == n[k]:
        continue
    print(f"{k[0]:<14}{k[1]:<8}{k[2]:<12}{k[3]:<8}{k[4]:<6}"
          f"{g[k]:>7}{o[k]:>7}{n[k]:>7}")
dp = sum(abs(g[k] - o[k]) for k in keys)
dn = sum(abs(g[k] - n[k]) for k in keys)
print(f"\nMULTISET DISTANCE to golden over ALL cells: pristine={dp}  patched={dn}")
print("VERDICT:", "IMPROVED" if dn < dp else ("UNCHANGED" if dn == dp else "WORSE"))
