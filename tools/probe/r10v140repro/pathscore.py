#!/usr/bin/env python3
# r10v140 — score one arm/view with the BROAD path census.
# usage: pathscore.py <gold.dump> <pris.dump> <pat.dump> <label>
import sys, os, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pathcen import census
g, o, q, lab = census(sys.argv[1]), census(sys.argv[2]), census(sys.argv[3]), sys.argv[4]
keys = sorted(set(g) | set(o) | set(q))
t = collections.Counter()
for k in keys:
    gv, ov, qv = g.get(k), o.get(k), q.get(k)
    if ov == qv:
        t['UNCHANGED-OK' if gv == ov else 'UNCHANGED-WRONG'] += 1
        continue
    if gv == qv and gv != ov: v = 'TOGOLD'
    elif gv == ov and gv != qv: v = 'MOVED-WRONG'
    elif gv is None: v = 'CHANGED-NOGOLD'
    else: v = 'CHANGED-STILL-WRONG'
    t[v] += 1
    if v in ('MOVED-WRONG', 'CHANGED-STILL-WRONG', 'CHANGED-NOGOLD'):
        print('%s\t%s\t%s\tGOLD=%s\tPRIS=%s\tPAT=%s' % (v, lab, k, gv, ov, qv))
print('PATHTALLY\t%s\t%s' % (lab, '\t'.join('%s=%d' % kv for kv in sorted(t.items()))))
