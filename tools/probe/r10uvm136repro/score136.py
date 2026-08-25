#!/usr/bin/env python3
"""r10uvm136 — score a cen136 golden / pristine / patched triple.

LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
  usage: score136.py <g.cen> <o.cen> [<q.cen>]

The key is (SITE, IDX, property name) — never the span, never the file (our
objects carry an empty VpiFile and spans are dump fidelity, not judge-visible).
Rows are a MULTISET: a repeated key keeps every row.  It reports, per cell,
the golden / pristine / patched VARIABLE CLASS, and scores the patch as
  FIXED         pristine != golden, patched == golden
  MOVED-WRONG   pristine == golden, patched != golden   (a regression)
  AWAY          pristine != golden, patched != golden, patched != pristine
  STILL-WRONG   pristine != golden, patched == pristine (untouched residue)
plus the ONE-SIDED sets (a cell only golden has, or only ours) — a pass that
adds or removes objects must score those explicitly.
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 5: continue
        v = f[3].split("|")
        d[(f[1], f[2], v[1])].append((v[0], f[4]))
    return d

g = load(sys.argv[1]); o = load(sys.argv[2])
q = load(sys.argv[3]) if len(sys.argv) > 3 else None
keys = sorted(set(g) | set(o) | (set(q) if q else set()))
cnt = collections.Counter()
rows = []
for k in keys:
    gv = g.get(k, []); ov = o.get(k, []); qv = q.get(k, []) if q else None
    if not gv:  cnt["ONLY-OURS"] += len(ov);  rows.append(("ONLY-OURS", k, "-", ov[0][0] if ov else "-", "-")); continue
    if not ov:  cnt["ONLY-GOLDEN"] += len(gv); rows.append(("ONLY-GOLDEN", k, gv[0][0], "-", "-")); continue
    for i in range(max(len(gv), len(ov))):
        G = gv[i][0] if i < len(gv) else "-"
        O = ov[i][0] if i < len(ov) else "-"
        Q = (qv[i][0] if qv and i < len(qv) else "-") if q else None
        if G == "-":
            # golden has FEWER rows at this key: a SURPLUS object of ours (an
            # object golden does not have at all).  It is scored one-sided, not
            # as an AWAY — there is no golden value to move away from.
            cnt["ONLY-OURS"] += 1; rows.append(("ONLY-OURS-DUP", k, G, O, Q if q else "-")); continue
        if O == "-":
            cnt["ONLY-GOLDEN"] += 1; rows.append(("ONLY-GOLDEN-DUP", k, G, O, Q if q else "-")); continue
        if q is None:
            tag = "AGREE" if G == O else "PRIS-WRONG"
        elif G == O and G == Q:      tag = "AGREE"
        elif G != O and Q == G:      tag = "FIXED"
        elif G == O and Q != G:      tag = "MOVED-WRONG"
        elif G != O and Q == O:      tag = "STILL-WRONG"
        else:                        tag = "AWAY"
        cnt[tag] += 1
        if tag != "AGREE": rows.append((tag, k, G, O, Q if q else "-"))
for t in ("AGREE","FIXED","STILL-WRONG","MOVED-WRONG","AWAY","ONLY-GOLDEN","ONLY-OURS"):
    print(f"{t}={cnt[t]}")
print("PRIS  wrong cells =", cnt["FIXED"]+cnt["STILL-WRONG"]+cnt["MOVED-WRONG"]*0)
for r in rows:
    print("  ", r[0], "\t", r[1][2], "\tG=", r[2], "\tO=", r[3], "\tQ=", r[4], "\t", r[1][0][-90:])
