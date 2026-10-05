#!/usr/bin/env python3
# v11u255 ctlsum.py <controls.txt>: per case-view the pristine and law lines of r11u255repro/drivers/controls.sh;
# prints every mover (verdicts, uhdm-cmp line counts) and every exit-code difference, then the totals. Reads only
# the controls file (no database, no source).
import sys, collections
r = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split(); cv, tag = f[0], f[1]
    d = dict(x.split('=', 1) for x in f[2:] if '=' in x); d['raw'] = ' '.join(f[2:])
    r[cv][tag] = d
t = collections.Counter()
for cv in sorted(r):
    P, L = r[cv].get('pristine', {}), r[cv].get('law', {})
    t['case-views'] += 1
    if P.get('rc') != L.get('rc'): t['rc differ'] += 1; print('RC', cv, P.get('rc'), L.get('rc'))
    if P.get('md5') != L.get('md5'):
        t['moving'] += 1
        ps, ls = P.get('strict', P['raw']), L.get('strict', L['raw'])
        if ls.startswith('STRICT_EQUAL') and not ps.startswith('STRICT_EQUAL'): t['entering'] += 1
        if ps.startswith('STRICT_EQUAL') and not ls.startswith('STRICT_EQUAL'): t['LEAVING'] += 1
        print('MOVE', cv, ps, '->', ls, 'cmp', P.get('cmplines'), '->', L.get('cmplines'))
    if P.get('rc') not in ('0', None): t['nonzero rc (pristine)'] += 1
print(dict(t))
