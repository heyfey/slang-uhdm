#!/usr/bin/env python3
"""r10v155 — a SPAN-INDEPENDENT, REF-AWARE cell score.

`scorecell155.py` keys on the declaration's own span, which is right for the
DECL census but cannot join golden's `ref_var` (Surelog spans it at the WRITTEN
TYPE, CompileType.cpp:421-431 + populateCoreMembers) with ours (spanned at the
NAME).  This one keys on (VIEW, ROWTYPE, OWNER, NAME) and compares the payload
WITHOUT any span, so a cell whose only residue is the span reads SAME and a
cell whose KIND moved reads DIFF.  REF rows are included, so the collateral a
declaration's kind change has on the references BOUND to it is visible.

LHS/G is ALWAYS golden.  MEASUREMENT ONLY.
usage: scoreref155.py <cen.g.txt> <cen.o.txt>
"""
import sys, collections
def load(p):
    m = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 14 or f[1] == "TP":
            continue
        # key: view, row type, owner, name.  payload: kinds + typespec name only.
        m[(f[2], f[1], f[5], f[7])].append((f[8], f[10], f[11], f[12]))
    return {k: sorted(v) for k, v in m.items()}
g = load(sys.argv[1]); o = load(sys.argv[2])
for k in sorted(set(g) | set(o)):
    gv = g.get(k); ov = o.get(k)
    tag = "SAME" if gv == ov else ("ONLY-G" if not ov else ("ONLY-O" if not gv else "DIFF"))
    print("%s\t%s\tG=%s\tO=%s" % (tag, "|".join(k), gv, ov))
