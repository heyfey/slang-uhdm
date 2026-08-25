#!/usr/bin/env python3
"""r10uvm149 -- MULTISET JOIN over ct149cen rows.  MEASUREMENT ONLY.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

Reads a golden census file and an ours census file for the SAME row-mode and
scores the cells:

  SAME              key present both sides with the SAME payload multiset
  MOVED-WRONG       key present both sides, payloads differ
  ONLY-GOLDEN       (key,payload) cell golden has and we do not
  ONLY-OURS         (key,payload) cell we have and golden does not

The join is a MULTISET join on (key, payload): keys COLLIDE across the DEF and
ELABORATED views of the same struct (the view is deliberately out of the key)
and a last-writer dict would silently drop rows.  Nothing is deduped, so no
AWAY-GOLDEN phantom can be manufactured.

  usage: cen149.py <golden.txt> <ours.txt> [--rows] [--kinds]
         cen149.py --calib <golden.txt> <golden.txt>
"""
import sys
from collections import Counter, defaultdict


def load(path):
    rows = []
    for ln in open(path):
        if not ln.startswith("M\t"):
            continue
        f = ln.rstrip("\n").split("\t")
        # M label key packed shape dflt file
        rows.append((f[2], f[3] + "\t" + f[4] + "\t" + f[5], f[6] if len(f) > 6 else ""))
    return rows


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    flags = {a for a in sys.argv[1:] if a.startswith("--")}
    g, o = load(args[0]), load(args[1])
    gc = Counter((k, p) for k, p, _ in g)
    oc = Counter((k, p) for k, p, _ in o)
    gkeys = Counter(k for k, _, _ in g)
    okeys = Counter(k for k, _, _ in o)
    only_g = gc - oc
    only_o = oc - gc
    shared = sum((gc & oc).values())
    moved = sorted({k for k, _ in only_g} & {k for k, _ in only_o})
    onlyg_keys = sorted({k for k, _ in only_g} - {k for k, _ in only_o})
    onlyo_keys = sorted({k for k, _ in only_o} - {k for k, _ in only_g})
    print(f"GOLDEN cells={sum(gc.values())} keys={len(gkeys)}")
    print(f"OURS   cells={sum(oc.values())} keys={len(okeys)}")
    print(f"SAME cells={shared}")
    print(f"MOVED-WRONG keys={len(moved)} cells="
          f"{sum(v for (k, p), v in only_g.items() if k in set(moved))}")
    print(f"ONLY-GOLDEN-KEY keys={len(onlyg_keys)} cells="
          f"{sum(v for (k, p), v in only_g.items() if k in set(onlyg_keys))}")
    print(f"ONLY-OURS-KEY keys={len(onlyo_keys)} cells="
          f"{sum(v for (k, p), v in only_o.items() if k in set(onlyo_keys))}")
    if "--kinds" in flags:
        # per-key-shape tally of the WRONG cells, keyed on golden's ts kind
        # vs ours -- the census the law is scored on.
        tal = Counter()
        for k in moved:
            gk = sorted({p.split("\t")[1].split()[0] for (kk, p) in only_g if kk == k})
            ok = sorted({p.split("\t")[1].split()[0] for (kk, p) in only_o if kk == k})
            tal[(",".join(gk), ",".join(ok))] += 1
        for (a, b), n in sorted(tal.items(), key=lambda x: -x[1]):
            print(f"KINDPAIR gold={a} ours={b} keys={n}")
    if "--rows" in flags:
        for k in moved:
            for (kk, p), v in sorted(only_g.items()):
                if kk == k:
                    print(f"WRONG-G x{v} {kk}\n         G: {p}")
            for (kk, p), v in sorted(only_o.items()):
                if kk == k:
                    print(f"         O: {p}")
        for k in onlyg_keys:
            for (kk, p), v in sorted(only_g.items()):
                if kk == k:
                    print(f"ONLYG x{v} {kk}\n         G: {p}")
        for k in onlyo_keys:
            for (kk, p), v in sorted(only_o.items()):
                if kk == k:
                    print(f"ONLYO x{v} {kk}\n         O: {p}")


main()
