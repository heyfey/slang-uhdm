#!/usr/bin/env python3
"""r10rgg7/verdict.py -- the ORDER-BLIND verdict over score.py's join.

  usage: verdict.py <score.txt>
FIXED   base disagreed with golden, patched agrees
BROKEN  base agreed, patched does not          <-- the only fatal class
STILL   neither agrees
OK      both agree
"""
import sys, collections
c = collections.Counter()
rows = collections.defaultdict(list)
for l in open(sys.argv[1]):
    p = l.split()
    if len(p) < 7 or p[0] in ('CELL',) or l.startswith('--') or l.startswith('   '):
        continue
    cell, view, inst, n, gold, base, pat = p[0], p[1], p[2], p[3], p[4], p[5], p[6]
    v = ('OK' if gold == base == pat else
         'FIXED' if gold != base and gold == pat else
         'BROKEN' if gold == base and gold != pat else 'STILL')
    c[(view, v)] += 1
    rows[v].append('%s %s %s gold=%s base=%s pat=%s' % (cell, view, inst, gold, base, pat))
for k in sorted(c):
    print('%-5s %-7s %d' % (k[0], k[1], c[k]))
for v in ('BROKEN', 'STILL'):
    for r in rows[v]:
        print('  %-7s %s' % (v, r))
print('TOTAL rows=%d  BROKEN=%d' % (sum(c.values()),
                                    sum(v for k, v in c.items() if k[1] == 'BROKEN')))
