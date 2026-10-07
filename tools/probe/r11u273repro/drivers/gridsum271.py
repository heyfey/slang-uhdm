#!/usr/bin/env python3
# (r11u273: copied from r11u271repro/drivers)
# r11u271 gridsum271.py <grid.txt>: the grid summary. Per case-view: pristine (P) vs law (L) strict verdict and md5,
# R11U271_OFF (OFF) against pristine's bytes, each switch's bytes; a mover is attributed to the switches whose
# config returns pristine's bytes. Prints totals and every mover line.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p = l.split()
    if len(p) < 4: continue
    cfg, rel = p[0], p[1]
    f = dict(x.split('=', 1) for x in p[3:] if '=' in x)
    rows[rel][cfg] = f
sw = sorted({c for r in rows.values() for c in r if c.startswith('R11U271_')})
tot = collections.Counter()
for rel in sorted(rows):
    r = rows[rel]
    P, L, O = r.get('P'), r.get('L'), r.get('OFF')
    if not (P and L and O): tot['incomplete'] += 1; print('INCOMPLETE', rel); continue
    tot['caseviews'] += 1
    if P.get('rc') != L.get('rc'): tot['rc_changed'] += 1; print('RC', rel, P.get('rc'), L.get('rc'))
    if O.get('md5') != P.get('md5'): tot['off_not_pristine'] += 1; print('OFFDIFF', rel)
    if L.get('md5') == P.get('md5'): continue
    tot['moving'] += 1
    att = [s for s in sw if r.get(s, {}).get('md5') == P.get('md5')]
    tot['attrib_%d' % len(att)] += 1
    for a in att: tot['by_' + a] += 1
    ps, ls = P.get('strict', ''), L.get('strict', '')
    if ls.startswith('STRICT_EQUAL') and not ps.startswith('STRICT_EQUAL'): tot['entering'] += 1
    if ps.startswith('STRICT_EQUAL') and not ls.startswith('STRICT_EQUAL'): tot['leaving'] += 1; print('LEAVING', rel)
    if P.get('cmplines') == '0' and L.get('cmplines') != '0': tot['losing_cmp'] += 1; print('LOSECMP', rel)
    print('MOVER', rel, ps, '->', ls, 'by', ','.join(att) or '-')
print(' '.join('%s=%d' % kv for kv in sorted(tot.items())))
