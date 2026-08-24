#!/usr/bin/env python3
"""r10uvm123 — DIRECTION score for one row: golden vs pristine vs patched, over
the cast-target census (cast123).  LHS IS ALWAYS GOLDEN.

Cells are keyed by (view, op span) and compared as MULTISETS of payloads, so a
site with two views/copies is never collapsed by a last-writer dict.
Reports  TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / ALREADY-GOLDEN.
MEASUREMENT ONLY — the official uhdm-cmp is the judge.
  usage: score123.py g.cast o.cast q.cast
"""
import sys, collections
def load(p):
    m = collections.defaultdict(collections.Counter)
    for ln in open(p):
        f = ln.split()
        if not f or f[0] != 'CAST': continue
        m[(f[1], f[2])][' '.join(f[3:])] += 1
    return m
g, o, q = (load(a) for a in sys.argv[1:4])
keys = sorted(set(g) | set(o) | set(q))
to = away = still = ok = 0
for k in keys:
    G, O, Q = g.get(k, collections.Counter()), o.get(k, collections.Counter()), q.get(k, collections.Counter())
    if O == Q:
        if G == O: ok += 1
        else: still += 1
        continue
    # the cell changed: did it become golden's multiset?
    dO = sum(((O - G) + (G - O)).values())
    dQ = sum(((Q - G) + (G - Q)).values())
    if dQ < dO: to += 1
    elif dQ > dO: away += 1
    else: still += 1
print(f"cells={len(keys)} TO-GOLDEN={to} AWAY-GOLDEN={away} STILL-WRONG={still} ALREADY-GOLDEN={ok}")
for k in keys:
    G, O, Q = g.get(k, collections.Counter()), o.get(k, collections.Counter()), q.get(k, collections.Counter())
    if O != Q or G != Q:
        print(f"-- {k}")
        for t, C in (('G', G), ('O', O), ('Q', Q)):
            for p, n in sorted(C.items()): print(f"   {t} x{n} {p}")
