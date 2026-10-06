#!/usr/bin/env python3
# v11u258 widensum.py <widen.txt>: per case-view the pristine (P), law (L) and fix (F) case.sh verdicts; prints every
# case-view whose bytes move (L vs P or F vs L) and the totals: moving, entering / leaving STRICT_EQUAL, exit code or
# uhdm-cmp line count changes. Reads only the case.sh lines (no database is opened).
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    d = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    d['v'] = d.get('strict', f[3] if len(f) > 3 else '?')
    rows[f[1]][f[0]] = d
t = collections.Counter()
for cv in sorted(rows):
    r = rows[cv]; P, L, F = r.get('P', {}), r.get('L', {}), r.get('F', {})
    t['case-views'] += 1
    if not (P and L and F): t['incomplete'] += 1; print('INCOMPLETE', cv); continue
    lp = L.get('md5') != P.get('md5'); fl = F.get('md5') != L.get('md5')
    if lp: t['law moving'] += 1
    if fl: t['fix vs law moving'] += 1
    if L['v'].startswith('STRICT_EQUAL') and not P['v'].startswith('STRICT_EQUAL'): t['entering STRICT_EQUAL'] += 1
    if P['v'].startswith('STRICT_EQUAL') and not L['v'].startswith('STRICT_EQUAL'): t['LEAVING STRICT_EQUAL'] += 1
    if len({P.get('rc'), L.get('rc'), F.get('rc')}) > 1: t['rc changed'] += 1
    if P.get('cmplines') != L.get('cmplines'): t['cmplines changed'] += 1
    if P.get('rc') not in (None, '0'): t['nonzero rc (all binaries)'] += 1
    if lp or fl:
        print(f"{'MOVER' if lp else 'FIXMOVER'} {cv} P={P['v']} L={L['v']} F={F['v']} rc={P.get('rc')}/{L.get('rc')}/{F.get('rc')} cmplines={P.get('cmplines')}->{L.get('cmplines')}")
print(' '.join(f'{k}={v}' for k, v in t.items()))
