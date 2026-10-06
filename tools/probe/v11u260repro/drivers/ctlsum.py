#!/usr/bin/env python3
# (r11u258: copied from r11u259repro/drivers)
# r11u258 ctlsum.py <controls.txt>: the byte-control summary (pristine vs law per case-view): movers, STRICT_EQUAL
# entering / leaving, exit-code and uhdm-cmp line-count changes, every mover listed.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    d = dict(x.split('=', 1) for x in f[2:] if '=' in x); d['raw'] = ' '.join(f[2:])
    rows[f[0]][f[1]] = d
mv, ent, lea, rc, cm = [], [], [], [], []
for cv, r in sorted(rows.items()):
    P, L = r.get('pristine', {}), r.get('law', {})
    ps, ls = P.get('strict', P.get('raw', '')), L.get('strict', L.get('raw', ''))
    if P.get('md5') != L.get('md5'): mv.append(f'{cv} {ps} -> {ls} cmplines {P.get("cmplines")}->{L.get("cmplines")}')
    if ls.startswith('STRICT_EQUAL') and not ps.startswith('STRICT_EQUAL'): ent.append(cv)
    if ps.startswith('STRICT_EQUAL') and not ls.startswith('STRICT_EQUAL'): lea.append(cv)
    if P.get('rc') != L.get('rc'): rc.append(cv)
    if P.get('cmplines') != L.get('cmplines'): cm.append(cv)
print(f'case-views={len(rows)} moving={len(mv)} entering={len(ent)} leaving={len(lea)} rc-changed={len(rc)} cmplines-changed={len(cm)}')
for x in mv: print('MOVER', x)
for x in ent: print('ENTER', x)
for x in lea: print('LEAVE', x)
for x in rc + cm: print('CHANGED', x)
