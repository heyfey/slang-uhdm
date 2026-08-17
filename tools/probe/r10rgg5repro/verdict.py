#!/usr/bin/env python3
"""r10rgg5/verdict.py -- the order-blind FIXED / BROKEN / STILL / OK join.

Reads score.py's table (stdin or a file) and classifies every row that GOLDEN,
BASE and PAT all have.  The verdict that decides acceptance is BROKEN: a row
GOLDEN==BASE and PAT!=GOLDEN.  Rows golden has and ours does not (and vice
versa) are counted separately as GOLD-ONLY / OURS-ONLY -- they are SHAPE
divergences, not value ones, and lumping them in would flatter or damn the pass
for the wrong reason.
"""
import sys, collections, re

rows = [l.rstrip('\n') for l in open(sys.argv[1], errors='replace')]
tally = collections.Counter()
detail = collections.defaultdict(list)
for L in rows[1:]:
    if L.startswith('MISS=') or not L.strip():
        continue
    f = L.split()
    if len(f) < 5:
        continue
    cell, inst, g, b, p = f[0], f[1] + ' ' + f[2], f[3], f[4], f[5] if len(f) > 5 else '-'
    if g in ('-/-', 'MISS'):
        tally['OURS-ONLY(no golden object)'] += 1; continue
    if b == 'MISS' or p == 'MISS':
        tally['GOLD-ONLY(we emit no object)'] += 1
        detail['GOLD-ONLY'].append('%s %s' % (cell, inst)); continue
    if b == g and p == g:
        tally['OK(both match golden)'] += 1
    elif b != g and p == g:
        tally['FIXED'] += 1; detail['FIXED'].append('%s %s' % (cell, inst))
    elif b == g and p != g:
        tally['BROKEN'] += 1; detail['BROKEN'].append('%s %s' % (cell, inst))
    elif b == p:
        tally['STILL(unchanged, still != golden)'] += 1
        detail['STILL'].append('%s %s' % (cell, inst))
    else:
        tally['MOVED-WRONG(was wrong, still wrong, changed)'] += 1
        detail['MOVED-WRONG'].append('%s %s' % (cell, inst))
for k in sorted(tally):
    print('%-46s %d' % (k, tally[k]))
for k in ('BROKEN', 'FIXED', 'MOVED-WRONG', 'STILL', 'GOLD-ONLY'):
    if detail[k]:
        print('-- %s (%d)' % (k, len(detail[k])))
        for d in detail[k]:
            print('     ' + d)
print('VERDICT: %s' % ('BROKEN=0, ACCEPT' if tally['BROKEN'] == 0 else 'BROKEN>0, REJECT'))
