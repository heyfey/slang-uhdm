#!/usr/bin/env python3
"""r10uvm216 — the census MULTISET JOIN.  MEASUREMENT ONLY.

Reads two `ct216cen` keycount files (golden first, ours second) and prints the
per-key delta as a MULTISET join: keys collide, and a last-writer dict silently
drops rows (RESUME.md §9, census traps), so both sides are counted, not mapped.

Output rows:
  RIGHT-BOTH  <n>  <key>     both sides hold the key n times
  ONLY-GOLDEN <n>  <key>     golden holds it n times more than we do
  ONLY-OURS   <n>  <key>     we hold it n times more than golden does
Last line is the summary the grid driver greps.

usage: cen216.py <golden.kc> <ours.kc> [--only-diff]
"""
import sys
from collections import Counter


def load(p):
    c = Counter()
    with open(p) as f:
        for line in f:
            line = line.rstrip("\n")
            if not line:
                continue
            n, _, key = line.partition("\t")
            try:
                c[key] += int(n)
            except ValueError:
                pass
    return c


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    g = load(sys.argv[1])
    o = load(sys.argv[2])
    only_diff = "--only-diff" in sys.argv[3:]
    both = og = oo = 0
    rows = []
    for k in sorted(set(g) | set(o)):
        gn, on = g.get(k, 0), o.get(k, 0)
        common = min(gn, on)
        if common and not only_diff:
            rows.append(("RIGHT-BOTH", common, k))
        both += common
        if gn > on:
            rows.append(("ONLY-GOLDEN", gn - on, k))
            og += gn - on
        elif on > gn:
            rows.append(("ONLY-OURS", on - gn, k))
            oo += on - gn
    for tag, n, k in rows:
        print(f"{tag}\t{n}\t{k}")
    print(f"-- RIGHT-BOTH={both} ONLY-GOLDEN={og} ONLY-OURS={oo}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
