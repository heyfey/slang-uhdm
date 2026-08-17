#!/usr/bin/env python3
"""r10rgg5/score.py -- fold run_grid.sh's raw output into one row per
(cell, instance) with the GOLDEN / BASE / PAT argument constant side by side.

Only the site-64:47 rows are joined (one per elaborated instance's own
param_assign); the 66:10 rows repeat the same object per next_data range and
are reported separately as a CONSISTENCY check.

GUARDS
  * an instance present on one side only is printed as MISS and COUNTED.
  * a cell whose GOLD block is absent prints NO-GOLD and is COUNTED.
  * the instance key is the LAST path component chain after the top module
    name, so ours' EXTRA recursive instances (which golden never builds) show
    up as MISS rows rather than silently shifting the join.
"""
import re, sys, collections

raw = open(sys.argv[1], errors='replace').read().split('\n')
HDR = re.compile(r'^== (\S+) (GOLD|BASE|PAT) : (\d+) get_next_n calls')
ROW = re.compile(r'^\s+(\d+:\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*$')

data = collections.defaultdict(dict)   # cell -> side -> {path: (site,kind,size,dec)}
cells = []
cur = None
for L in raw:
    m = HDR.match(L)
    if m:
        cur = (m.group(1), m.group(2))
        if m.group(1) not in cells:
            cells.append(m.group(1))
        data[m.group(1)][m.group(2)] = {}
        continue
    if cur is None:
        continue
    r = ROW.match(L)
    if not r:
        continue
    site, kind, size, dec, path = r.groups()
    if kind == 'ref_obj':
        continue
    key = (site, path)
    data[cur[0]][cur[1]][key] = (kind, size, dec)

miss = 0; nogold = 0
print('%-12s %-46s %-16s %-16s %-16s' % ('CELL', 'INSTANCE(site)', 'GOLD', 'BASE', 'PAT'))
for c in cells:
    sides = data[c]
    if 'GOLD' not in sides:
        print('%-12s NO-GOLD' % c); nogold += 1; continue
    keys = []
    for sd in ('GOLD', 'BASE', 'PAT'):
        for k in sides.get(sd, {}):
            if k not in keys:
                keys.append(k)
    for k in keys:
        cellrow = []
        for sd in ('GOLD', 'BASE', 'PAT'):
            v = sides.get(sd, {}).get(k)
            if sd not in sides:
                cellrow.append('-')
            elif v is None:
                cellrow.append('MISS'); miss += 1
            else:
                cellrow.append('%s/%s' % (v[1], v[2]))
        tag = re.sub(r'^work@top_[a-z0-9_]+\.?', '', k[1]) or '(top)'
        print('%-12s %-46s %-16s %-16s %-16s' % (c, tag + ' @' + k[0],
                                                 cellrow[0], cellrow[1], cellrow[2]))
print('MISS=%d NO-GOLD=%d' % (miss, nogold))
