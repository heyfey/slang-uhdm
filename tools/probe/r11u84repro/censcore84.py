#!/usr/bin/env python3
"""r11u84 CENSUS SCORER — name every corpus mover BY NAME, a priori, from ONE
binary.  Three trace rows, three mover classes:
  R11U84CELL ... MOVED   LAW A: the clone's two readings disagree
  R11U84EXP  ... MINT    LAW B: an explicit import adds a listing entry
  R11U84ORD  ... MOVED   LAW C: the listing's clone batch changes slot
A row whose invocation did not return rc=0 teaches error recovery, not golden,
and is counted separately."""
import sys, collections
cell = collections.Counter(); exp = collections.Counter(); ordr = collections.Counter()
movers = collections.defaultdict(set)
rc_bad = collections.Counter(); nosite = 0; inv = set()
for l in open(sys.argv[1]):
    p = l.rstrip('\n').split('\t')
    if len(p) < 4: continue
    test, mode, rc, row = p[0], p[1], p[2], p[3]
    inv.add((test, mode))
    if rc != 'rc=0': rc_bad[rc] += 1
    if row == 'NO-SITE-ROW': nosite += 1; continue
    kv = dict(x.split('=', 1) for x in row.split() if '=' in x)
    tag = row.split()[-1]
    if row.startswith('R11U84CELL'):
        cell[tag] += 1
        if tag == 'MOVED': movers[(test, mode)].add('A:' + kv.get('name', '?'))
    elif row.startswith('R11U84EXP'):
        exp[tag] += 1
        if tag == 'MINT': movers[(test, mode)].add('B:' + kv.get('name', '?'))
    elif row.startswith('R11U84ORD'):
        ordr[tag] += 1
        if tag == 'MOVED': movers[(test, mode)].add('C:' + kv.get('name', '?'))
print('invocations=%d  NO-SITE=%d  non-zero-rc rows=%s' % (len(inv), nosite, dict(rc_bad)))
print('LAW A cells : %s' % dict(cell))
print('LAW B items : %s' % dict(exp))
print('LAW C pkgs  : %s' % dict(ordr))
print('PREDICTED MOVER INVOCATIONS = %d' % len(movers))
for k in sorted(movers):
    print('  %-45s %s' % ('%s/%s' % k, sorted(movers[k])))
