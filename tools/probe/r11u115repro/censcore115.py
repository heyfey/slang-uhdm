#!/usr/bin/env python3
"""censcore115.py <golden.cen> <ours.cen>: one line of deltas (empty when none).
F1 keys: golden-minus-ours count; PV: multiset only_gold/only_ours counts (dedupe-safe)."""
import sys, collections
def rd(p):
    f1 = collections.Counter(); pv = collections.Counter()
    for l in open(p, errors='replace'):
        l = l.rstrip('\n')
        if l.startswith('F1 '):
            k, v = l.rsplit(' ', 1); f1[k] += int(v)
        elif l.startswith('PV '):
            pv[l] += 1
    return f1, pv
g1, gp = rd(sys.argv[1]); o1, op = rd(sys.argv[2])
out = []
for k in sorted(set(g1) | set(o1)):
    d = g1[k] - o1[k]
    if d: out.append(f"{k.replace('F1 ','').replace(' ','_')}{d:+d}")
og = sum((gp - op).values()); oo = sum((op - gp).values())
if og or oo: out.append(f"PV:gold_only={og},ours_only={oo}")
print(' '.join(out))
