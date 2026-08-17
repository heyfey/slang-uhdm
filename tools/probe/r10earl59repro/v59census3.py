#!/usr/bin/env python3
"""r10earl59 VERIFIER — memory-lean 3-WAY keyed census over three uhdm dumps.
Scans one dump at a time (peak = one dump's lines), keys via census59.py's own
scan(), and attributes every changed cell TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG.
usage: census3.py <golden.dump> <pris.dump> <pat.dump> [--rows N]
"""
import sys, collections, importlib.util, gc
spec = importlib.util.spec_from_file_location(
    'c', __import__('os').path.join(__import__('os').path.dirname(__import__('os').path.abspath(__file__)),'census59.py'))
mm = importlib.util.module_from_spec(spec); spec.loader.exec_module(mm)
g, p, q = sys.argv[1], sys.argv[2], sys.argv[3]
G = mm.scan(g); gc.collect()
P = mm.scan(p); gc.collect()
Q = mm.scan(q); gc.collect()
print('keyed rows: golden=%d pris=%d pat=%d' % (len(G), len(P), len(Q)))
t = collections.Counter(); fam = collections.Counter(); rows = []
for k in set(G) | set(P) | set(Q):
    gv, pv, qv = G.get(k, 'NO-ROW'), P.get(k, 'NO-ROW'), Q.get(k, 'NO-ROW')
    if pv == qv:
        t['UNMOVED-GOOD' if pv == gv else 'UNMOVED-BAD'] += 1
        continue
    tag = 'TO-GOLDEN' if qv == gv else ('AWAY-GOLDEN' if pv == gv else 'STILL-WRONG')
    t[tag] += 1
    fam[(tag, k[0], k[2], k[3], k[4],
         str(gv), str(pv), str(qv))] += 1
    if tag != 'TO-GOLDEN':
        rows.append((tag, k, gv, pv, qv))
print('== 3-WAY', dict(t))
print('== FAMILIES (tag, scopekind, extent, slot, refname, G, P, Q)')
for f, c in fam.most_common(20):
    print('  %6d %s' % (c, f))
for r in rows[:20]:
    print('  !! %s %s G=%s P=%s Q=%s' % r)
