#!/usr/bin/env python3
"""r10uvm123 — MULTISET join of two cen123 outputs.  LHS IS ALWAYS GOLDEN.
Keys collide on purpose (two views name the same chain), so the join is a
multiset join per (SITE,REFFULL): the payload multisets are compared, never a
last-writer dict.  MEASUREMENT ONLY.
  usage: join123.py golden.cells ours.cells [--full]
"""
import sys, collections, signal
try: signal.signal(signal.SIGPIPE, signal.SIG_DFL)   # `| head` must not traceback
except Exception: pass
def load(p):
    m = collections.defaultdict(collections.Counter)
    for ln in open(p):
        if not ln.startswith('CELL\t'): continue
        _, site, rfull, pay = ln.rstrip('\n').split('\t', 3)
        m[(site, rfull)][pay] += 1
    return m
g, o = load(sys.argv[1]), load(sys.argv[2])
full = '--full' in sys.argv
same = diff = gonly = oonly = 0
rows = []
for k in sorted(set(g) | set(o)):
    gc, oc = g.get(k, collections.Counter()), o.get(k, collections.Counter())
    if not oc: gonly += sum(gc.values()); rows.append(('GOLD-ONLY', k, gc, oc)); continue
    if not gc: oonly += sum(oc.values()); rows.append(('OURS-ONLY', k, gc, oc)); continue
    if gc == oc: same += sum(gc.values()); continue
    diff += 1; rows.append(('DIFF', k, gc, oc))
print(f"SAME={same} DIFFCELLS={diff} GOLD-ONLY={gonly} OURS-ONLY={oonly}")
for tag, k, gc, oc in rows:
    print(f"{tag}\t{k[1]}\t{k[0]}")
    for p, n in sorted(gc.items()): print(f"   G x{n} {p}")
    for p, n in sorted(oc.items()): print(f"   O x{n} {p}")
