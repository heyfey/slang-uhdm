#!/usr/bin/env python3
"""r10v143 — deep arm scorer.  MEASUREMENT ONLY; uhdm-cmp is the judge.
LHS IS ALWAYS GOLDEN.  usage: vscore143.py <gold.dump> <pris.dump> <pat.dump>"""
import sys, importlib.util, collections
spec = importlib.util.spec_from_file_location(
    "vcen", "/tmp/wt_v143/tools/probe/r10v143repro/vcen143.py")
src = open("/tmp/wt_v143/tools/probe/r10v143repro/vcen143.py").read()
src = src.split("if len(sys.argv) == 2:")[0]
ns = {}
exec(src, ns)
cells = ns['cells']
g, p, q = cells(sys.argv[1]), cells(sys.argv[2]), cells(sys.argv[3])
c = collections.Counter(); det = collections.defaultdict(list)
for k in set(g) | set(p) | set(q):
    if k not in g:
        c['ONLY-OURS'] += 1; det['ONLY-OURS'].append(k); continue
    if k not in p and k not in q:
        c['ONLY-GOLDEN'] += 1; det['ONLY-GOLDEN'].append(k); continue
    gv, pv, qv = g[k], p.get(k, '<absent>'), q.get(k, '<absent>')
    if pv == gv and qv == gv: c['ALREADY-RIGHT'] += 1
    elif pv != gv and qv == gv: c['TO-GOLDEN'] += 1; det['TO-GOLDEN'].append((k, pv, qv))
    elif pv == gv and qv != gv: c['AWAY-GOLDEN'] += 1; det['AWAY-GOLDEN'].append((k, gv, pv, qv))
    elif pv != qv: c['MOVED-WRONG'] += 1; det['MOVED-WRONG'].append((k, gv, pv, qv))
    else: c['STILL-WRONG'] += 1; det['STILL-WRONG'].append((k, gv, pv, qv))
print("  " + "  ".join(f"{k}={v}" for k, v in sorted(c.items())))
for t in ('AWAY-GOLDEN', 'MOVED-WRONG', 'STILL-WRONG', 'TO-GOLDEN'):
    for e in sorted(det[t], key=str):
        print(f"    {t}\t{e}")
