#!/usr/bin/env python3
"""r10uvm155 — the STRICT arm scorer.  MEASUREMENT ONLY.

score155.py compares KEY SETS, which is blind to a cell that was wrong before
and is DIFFERENTLY wrong after (same key, different payload).  This one emits
one canonical line per cell — key AND the full payload of BOTH sides — for the
pristine and the patched database, and reports:
  TOWARD  a cell that disagreed with golden and now agrees
  AWAY    a cell that agreed with golden and now disagrees
  RESHAPE a cell that disagreed before and disagrees DIFFERENTLY now
Any nonzero AWAY or RESHAPE is a failure of this pass.

--nospan drops the DECLARATION's OWN SPAN from the key, for the arms where a
PRE-EXISTING span residue puts golden's row at a different key from ours and a
span-keyed reading would call an unmoved span a RESHAPE.

usage: cellcmp155.py <cen.g.txt> <cen.pris.txt> <cen.pat.txt> [--nospan]
"""
import sys, collections

NOSPAN = "--nospan" in sys.argv

def load(p):
    m = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 14 or f[1] in ("REF", "CALL", "TP"):
            continue
        key = (f[2], f[5], "-" if NOSPAN else f[6], f[7])
        m[key].add((f[8], f[10], f[11], f[12], f[13]))
    return m

g, a, b = (load(x) for x in sys.argv[1:4])
tow = away = res = same = 0
for k in sorted(set(g) | set(a) | set(b)):
    gv = sorted(g.get(k, [])); av = sorted(a.get(k, [])); bv = sorted(b.get(k, []))
    if av == bv:
        same += 1
        continue
    ok_a, ok_b = (av == gv), (bv == gv)
    if ok_b and not ok_a:
        tow += 1; print(f"TOWARD \t{k}\n   was={av}\n   now={bv}")
    elif ok_a and not ok_b:
        away += 1; print(f"AWAY   \t{k}\n   was={av}\n   now={bv}")
    else:
        res += 1
        print(f"RESHAPE\t{k}\n   gold={gv}\n   was={av}\n   now={bv}")
print(f"-- unmoved={same} TOWARD={tow} AWAY={away} RESHAPE={res}")
