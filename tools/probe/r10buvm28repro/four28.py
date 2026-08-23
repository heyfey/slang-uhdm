#!/usr/bin/env python3
"""r10buvm28 FOUR-WAY arm scorer — MEASUREMENT ONLY.  LHS is always golden.
  ALREADY-OK : pristine agreed with golden and patched still does
  FIXED      : pristine disagreed, patched agrees          -> TO-GOLDEN
  BROKE      : pristine agreed, patched does not           -> AWAY (must be 0)
  STILL      : both disagree (value may still have changed)
usage: four28.py <G.dump> <PRI.dump> <PAT.dump> [lo hi]"""
import sys, importlib.util, os
spec = importlib.util.spec_from_file_location(
    'spanval', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'spanval.py'))
m = importlib.util.module_from_spec(spec)
src = open(spec.origin).read().replace('main()\n', '', 1)
exec(compile(src, spec.origin, 'exec'), m.__dict__)
G, P, Q = m.load(sys.argv[1]), m.load(sys.argv[2]), m.load(sys.argv[3])
lo, hi = (int(sys.argv[4]), int(sys.argv[5])) if len(sys.argv) > 5 else (0, 10**9)
tot = {'ALREADY-OK': 0, 'FIXED': 0, 'BROKE': 0, 'STILL': 0, 'STILL-CHANGED': 0}
for k in sorted(set(G) | set(P) | set(Q)):
    if not (lo <= k[0] <= hi):
        continue
    g, p, q = G.get(k), P.get(k), Q.get(k)
    if p == g and q == g: tot['ALREADY-OK'] += 1
    elif p != g and q == g: tot['FIXED'] += 1; print('FIXED         %d:%d-%d  G=%s P=%s' % (k+(sorted(g) if g else '-', sorted(p) if p else '-')))
    elif p == g and q != g: tot['BROKE'] += 1; print('BROKE         %d:%d-%d  G=%s Q=%s' % (k+(sorted(g) if g else '-', sorted(q) if q else '-')))
    else:
        tot['STILL'] += 1
        if p != q:
            tot['STILL-CHANGED'] += 1
            print('STILL-CHANGED %d:%d-%d  G=%s P=%s Q=%s' % (k+(sorted(g) if g else '-', sorted(p) if p else '-', sorted(q) if q else '-')))
print('== ' + '  '.join('%s %d' % (k, v) for k, v in tot.items()))
