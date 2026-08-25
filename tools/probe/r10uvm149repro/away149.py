#!/usr/bin/env python3
"""r10uvm149 -- TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG scorer over three
ct149cen files (golden, pristine, patched) for ONE database.  MEASUREMENT ONLY.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

A KEY is scored by comparing its PAYLOAD MULTISET on each side:
  TO-GOLDEN    wrong in pristine, equal to golden in patched
  AWAY-GOLDEN  equal to golden in pristine, wrong in patched   <-- must be 0
  MOVED-WRONG  wrong in both AND the payload multiset CHANGED  <-- must be 0
  STILL-WRONG  wrong in both, payload unchanged (a RESIDUE, named)
  SAME         equal in both

  usage: away149.py <golden.txt> <pristine.txt> <patched.txt> [--rows]
"""
import sys
from collections import Counter, defaultdict


def load(path):
    d = defaultdict(Counter)
    for ln in open(path):
        if not ln.startswith("M\t"):
            continue
        f = ln.rstrip("\n").split("\t")
        d[f[2]][f[3] + "\t" + f[4] + "\t" + f[5]] += 1
    return d


g, p, q = (load(a) for a in sys.argv[1:4])
rows = "--rows" in sys.argv
keys = sorted(set(g) | set(p) | set(q))
tal = Counter()
for k in keys:
    gk, pk, qk = g.get(k, Counter()), p.get(k, Counter()), q.get(k, Counter())
    was, now = (gk == pk), (gk == qk)
    if was and now:
        v = "SAME"
    elif not was and now:
        v = "TO-GOLDEN"
    elif was and not now:
        v = "AWAY-GOLDEN"
    elif pk == qk:
        v = "STILL-WRONG"
    else:
        v = "MOVED-WRONG"
    tal[v] += 1
    if rows and v != "SAME":
        print(f"{v}\t{k}")
        if v in ("STILL-WRONG", "MOVED-WRONG", "AWAY-GOLDEN"):
            for pay in sorted(gk):
                print(f"    G x{gk[pay]}: {pay}")
            for pay in sorted(qk):
                print(f"    Q x{qk[pay]}: {pay}")
print("  ".join(f"{k}={tal[k]}" for k in
                ("TO-GOLDEN", "AWAY-GOLDEN", "MOVED-WRONG", "STILL-WRONG", "SAME")))
