#!/usr/bin/env python3
# r10buvm34repro/dist34.py — order-blind MULTISET DISTANCE to golden, per
# arm-view, so an arm is SCORED rather than eyeballed: a landing may never
# raise dist(golden, patched) above dist(golden, pristine).  MEASUREMENT ONLY.
#   dist34.py <cells34.tsv> [--proj kind|full]
import collections, sys, re
p = sys.argv[1]
proj = sys.argv[sys.argv.index('--proj') + 1] if '--proj' in sys.argv else 'full'
S = collections.defaultdict(collections.Counter)
for l in open(p):
    f = l.rstrip('\n').split('\t')
    if len(f) < 15 or f[1] != 'FELV': continue
    side, view = f[0].split('|')
    ts = f[8] if proj == 'full' else re.sub(r'@[-0-9:]+$', '', f[8])
    S[(side, view)][(f[2], f[3], f[4], f[5], f[6], ts)] += 1
for view in ('def', 'elab'):
    g = S.get(('G', view))
    if not g: continue
    out = []
    for s in ('P', 'O'):
        o = S.get((s, view), collections.Counter())
        out.append(sum(((g - o) + (o - g)).values()))
    print(f"  {view:4s} dist(golden,pristine)={out[0]:5d}  dist(golden,patched)={out[1]:5d}  "
          + ("BETTER" if out[1] < out[0] else "SAME" if out[1] == out[0] else "*** WORSE ***"))
