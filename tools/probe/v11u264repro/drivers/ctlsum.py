#!/usr/bin/env python3
# (v11u264) ctlsum.py <controls.txt>: per case-view the pristine, law and fix lines; prints every mover against
# pristine (law, fix), entering / leaving STRICT_EQUAL, rc and uhdm-cmp line-count changes, and fix-vs-law movers.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    d = dict(x.split('=', 1) for x in f[2:] if '=' in x); d['raw'] = ' '.join(f[2:])
    rows[f[0]][f[1]] = d
t = collections.Counter()
for cv in sorted(rows):
    r = rows[cv]; P, L, F = r.get('pristine', {}), r.get('law', {}), r.get('fix', {})
    t['case-views'] += 1
    if P.get('rc') != L.get('rc') or P.get('rc') != F.get('rc'): t['rc changed'] += 1; print('RC', cv, P.get('rc'), L.get('rc'), F.get('rc'))
    if P.get('rc', '0') != '0': t[f"rc={P.get('rc')} (all three)"] += 1
    for tag, X in (('law', L), ('fix', F)):
        if X.get('md5') != P.get('md5'):
            t[f'{tag} movers'] += 1
            ps, xs = P.get('strict', P['raw']), X.get('strict', X['raw'])
            if xs.startswith('STRICT_EQUAL') and not ps.startswith('STRICT_EQUAL'): t[f'{tag} entering'] += 1
            if ps.startswith('STRICT_EQUAL') and not xs.startswith('STRICT_EQUAL'): t[f'{tag} LEAVING'] += 1
            if P.get('cmplines') != X.get('cmplines'): t[f'{tag} cmplines changed'] += 1
            print(f'MOVER {tag} {cv} {ps} -> {xs} cmplines {P.get("cmplines")}->{X.get("cmplines")}')
    if F.get('md5') != L.get('md5'): t['fix vs law movers'] += 1; print('FIXvsLAW', cv)
print(' '.join(f'{k}={v}' for k, v in sorted(t.items())))
