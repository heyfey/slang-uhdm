#!/usr/bin/env python3
"""r10uvm174 — join two ct174cen listings into the four-way fold table.
MEASUREMENT ONLY.  LHS is ALWAYS golden; RHS is ALWAYS ours.

A POSITION is (listing, home, name, line, col).  Rows:
  BOTH-KEEP     both producers left a sys_func_call there
  GOLDEN-ONLY   golden kept, we did not (we folded, or have no such position)
  OURS-ONLY     we kept, golden did not
"""
import sys, collections

def load(p):
    keep = {}
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if f[0] != "KEEP":
            continue
        key = (f[1], f[2], f[3], int(f[4]), int(f[5]))
        keep[key] = f[6] if len(f) > 6 else ""
    return keep

g = load(sys.argv[1])
o = load(sys.argv[2])
tag = sys.argv[3] if len(sys.argv) > 3 else ""
gk, ok = set(g), set(o)
both, gonly, oonly = gk & ok, gk - ok, ok - gk
print(f"{tag} BOTH-KEEP={len(both)} GOLDEN-ONLY={len(gonly)} OURS-ONLY={len(oonly)}")
for name, s in (("GOLDEN-ONLY", gonly), ("OURS-ONLY", oonly)):
    if not s:
        continue
    c = collections.Counter((k[0].split(":")[0], k[1].split("|", 1)[1], k[2]) for k in s)
    for k, v in sorted(c.items()):
        print(f"  {name}  listing={k[0]:9s} home={k[1]:22s} call={k[2]:8s} n={v}")
    for k in sorted(s):
        print(f"    {name} {k[0]} | {k[1]} | {k[2]} @{k[3]}:{k[4]}"
              f" | arg={(g if name=='GOLDEN-ONLY' else o)[k].strip()}")
