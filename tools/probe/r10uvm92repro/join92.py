#!/usr/bin/env python3
"""r10uvm92 — join a GOLDEN census against an OURS census on FILE|SPAN.

MEASUREMENT-ONLY.  LHS is ALWAYS golden.  Prints one line per differing key
plus the ONLY-GOLDEN / ONLY-OURS sets, so a row that vanishes on one side is
never silently dropped.  Usage: join92.py <g> <o> [--same]
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln or '\t' not in ln: continue
        k, rest = ln.split('\t', 1)
        d[k].append(rest)
    return d

g, o = load(sys.argv[1]), load(sys.argv[2])
show_same = '--same' in sys.argv
keys = sorted(set(g) | set(o))
ndiff = nsame = ngonly = noonly = 0
for k in keys:
    if k in g and k not in o:
        ngonly += 1; print(f"ONLY-GOLDEN {k}\n    G {g[k][0]}"); continue
    if k in o and k not in g:
        noonly += 1; print(f"ONLY-OURS   {k}\n    O {o[k][0]}"); continue
    gs, os_ = sorted(set(g[k])), sorted(set(o[k]))
    if gs == os_:
        nsame += 1
        if show_same: print(f"SAME {k}\n    = {gs[0]}")
        continue
    ndiff += 1
    print(f"DIFF {k}")
    for x in gs: print(f"    G {x}")
    for x in os_: print(f"    O {x}")
print(f"-- keys={len(keys)} SAME={nsame} DIFF={ndiff} ONLY-GOLDEN={ngonly} ONLY-OURS={noonly}")
