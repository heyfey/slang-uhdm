#!/usr/bin/env python3
# r11u279 gridsum279.py <grid.txt>: per case-view, P / L / OFF / each switch; OFF == P bytes, mover attribution
# (the switch whose OFF run gives P's bytes), verdict move P -> L, entering / leaving STRICT_EQUAL, cmp and rc changes.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    cfg, cv = f[0], f[1]
    kv = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    if 'SURELOG_FAIL' in l or 'SLANG_FAIL' in l: kv['strict'] = f[3]
    rows[cv][cfg] = kv
off_eq = moving = enter = leave = cmpch = rcch = 0
attr = collections.Counter()
for cv, d in sorted(rows.items()):
    P, L, O = d['P'], d['L'], d['OFF']
    off_eq += P.get('md5') == O.get('md5')
    if P.get('rc') != L.get('rc'): rcch += 1
    if P.get('cmplines') != L.get('cmplines'): cmpch += 1
    if P.get('md5') != L.get('md5'):
        moving += 1
        ps, ls = P.get('strict', ''), L.get('strict', '')
        e = ls.startswith('STRICT_EQUAL') and not ps.startswith('STRICT_EQUAL')
        lv = ps.startswith('STRICT_EQUAL') and not ls.startswith('STRICT_EQUAL')
        enter += e; leave += lv
        sws = [k for k in d if k.startswith('R11U279_') and k != 'R11U279_OFF' and d[k].get('md5') == P.get('md5')]
        attr[' '.join(sws) or 'NONE'] += 1
        print(f'{cv:28s} {ps:32s} -> {ls:28s} by {" ".join(sws) or "NONE"}')
print(f'case-views={len(rows)} OFF==P {off_eq}/{len(rows)} moving={moving} entering_STRICT_EQUAL={enter} leaving={leave} cmplines_changed={cmpch} rc_changed={rcch}')
print('attribution:', dict(attr))
