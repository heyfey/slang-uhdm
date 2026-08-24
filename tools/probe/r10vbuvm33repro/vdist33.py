#!/usr/bin/env python3
"""r10vbuvm33repro/vdist33.py — ORDER-BLIND MULTISET DISTANCE to golden on the
foreach-header VAR field, for a whole set of arms.  MEASUREMENT ONLY.

  vdist33.py <dumpdir> <arm> <view> [<arm> <view> ...]

Reads `<dumpdir>/dump.{g,p,q}.<arm>.<view>.txt` (golden / pristine / patched)
with `vgrid33.py`'s VIEW-GENERAL parser under PROJ=var and prints, per arm-view,
|G symdiff P| and |G symdiff Q|.  A landing may never make an arm FARTHER from
golden: `dist(golden,patched) > dist(golden,pristine)` is the number that must
never appear.
"""
import os, sys
os.environ['PROJ'] = 'var'
_here = os.path.dirname(os.path.abspath(__file__))
_src = open(os.path.join(_here, 'vgrid33.py')).read().split('G, P, Q = ')[0]
_ns = {}
exec(compile(_src, 'vgrid33', 'exec'), _ns)
parse = _ns['parse']

d0 = sys.argv[1]
pairs = list(zip(sys.argv[2::2], sys.argv[3::2]))
for a, v in pairs:
    try:
        G = parse('%s/dump.g.%s.%s.txt' % (d0, a, v))
        P = parse('%s/dump.p.%s.%s.txt' % (d0, a, v))
        Q = parse('%s/dump.q.%s.%s.txt' % (d0, a, v))
    except FileNotFoundError:
        print('%-8s %-5s MISSING' % (a, v))
        continue
    def dist(X, Y):
        return sum(abs(X[k] - Y[k]) for k in set(X) | set(Y))
    dp, dq = dist(G, P), dist(G, Q)
    print('%-8s %-5s dist(golden,pristine)=%-4d dist(golden,patched)=%-4d %s'
          % (a, v, dp, dq, 'WORSE' if dq > dp else ('better' if dq < dp else 'same')))
