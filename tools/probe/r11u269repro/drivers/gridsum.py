#!/usr/bin/env python3
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
# r11u267 gridsum.py <grid.txt>: per case-view the pristine and law verdicts, whether R11U269_OFF gives pristine's
# bytes, and which switches move the case back (the law that moves it); then the totals.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    cfg, cv = f[0], f[1]
    d = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    d['raw'] = ' '.join(f[3:])
    rows[cv][cfg] = d
tot = collections.Counter()
for cv in sorted(rows):
    r = rows[cv]; P, L, O = r.get('P', {}), r.get('L', {}), r.get('OFF', {})
    sw = [c.replace('R11U269_', '').replace('_OFF', '') for c in r if c.startswith('R11U269_') and r[c].get('md5') != L.get('md5')]
    off = 'off=pristine' if O.get('md5') == P.get('md5') else 'off=DIFFERS'
    pv, lv = P.get('strict', P.get('raw')), L.get('strict', L.get('raw'))
    mv = 'moves' if L.get('md5') != P.get('md5') else 'same'
    rc = 'rc=%s/%s' % (P.get('rc'), L.get('rc'))
    print(f'{cv:34s} P={pv:32s} L={lv:32s} {mv:5s} {off} {rc} switches-moving={",".join(sw) or "-"}')
    tot['case-views'] += 1
    tot[off] += 1
    if mv == 'moves': tot['moving'] += 1
    if lv.startswith('STRICT_EQUAL') and not pv.startswith('STRICT_EQUAL'): tot['entering STRICT_EQUAL'] += 1
    if pv.startswith('STRICT_EQUAL') and not lv.startswith('STRICT_EQUAL'): tot['LEAVING STRICT_EQUAL'] += 1
    if P.get('cmplines') != L.get('cmplines'): tot['cmplines changed'] += 1
    if P.get('rc') != L.get('rc'): tot['rc changed'] += 1
print(' '.join(f'{k}={v}' for k, v in sorted(tot.items())))
