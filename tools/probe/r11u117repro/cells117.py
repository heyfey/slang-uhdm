#!/usr/bin/env python3
"""cells117.py <out-root> <tagA> <tagB> — per-cell multiset scorer over the
normalised sorted dumps dist117.sh writes (<tag>.norm).  A cell is one distinct
dump line (kind + name + five-field span, or a field line); for each cell the
golden count g, A count a, B count b: TO += max(0,|a-g|-|b-g|), AWAY +=
max(0,|b-g|-|a-g|).  A nameless/parentless golden object is still a cell
(its line carries its kind and span; the ref's actual is the next cell).
Prints per arm and totals; with -v lists AWAY cells."""
import sys, os, collections
root, A, B = sys.argv[1:4]; verbose = '-v' in sys.argv
tt = ta = 0
for arm in sorted(os.listdir(root)):
    d = os.path.join(root, arm)
    fs = [os.path.join(d, t + '.norm') for t in ('gold', A, B)]
    if not all(os.path.exists(f) for f in fs): continue
    g, a, b = (collections.Counter(open(f).read().split('\n')) for f in fs)
    to = aw = 0; bad = []
    for k in set(g) | set(a) | set(b):
        da, db = abs(a[k] - g[k]), abs(b[k] - g[k])
        if db < da: to += da - db
        elif db > da: aw += db - da; bad.append((k, g[k], a[k], b[k]))
    tt += to; ta += aw
    if to or aw: print('%s TO=%d AWAY=%d' % (arm, to, aw))
    if verbose:
        for k, x, y, z in bad: print('   AWAY g=%d %s=%d %s=%d  %s' % (x, A, y, B, z, k.strip()))
print('TOTAL TO=%d AWAY=%d' % (tt, ta))
