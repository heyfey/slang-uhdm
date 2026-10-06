#!/usr/bin/env python3
# (v11u256) ctl3sum.py <controls3.txt>: per case-view the pristine / law / fix lines of drivers/controls3.sh; prints
# every case-view whose bytes move (law vs pristine, fix vs law), and the totals: moving, entering / leaving
# STRICT_EQUAL, exit-code and uhdm-cmp line-count changes.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    d = dict(x.split('=', 1) for x in f[2:] if '=' in x); d['raw'] = ' '.join(f[2:]); rows[f[0]][f[1]] = d
tot = collections.Counter()
v = lambda d: d.get('strict', d.get('raw', '?'))
for cv in sorted(rows):
    r = rows[cv]; P, L, X = r.get('pristine', {}), r.get('law', {}), r.get('fix', {})
    tot['case-views'] += 1
    for nm, a, b in (('law', P, L), ('fix-vs-law', L, X), ('fix', P, X)):
        if a.get('md5') != b.get('md5'):
            tot[nm + ' moving'] += 1
            if nm != 'fix': print(f'{nm:10s} {cv:60s} {v(a):30s} -> {v(b):30s} rc={a.get("rc")}/{b.get("rc")} cmplines={a.get("cmplines")}/{b.get("cmplines")}')
        if v(b).startswith('STRICT_EQUAL') and not v(a).startswith('STRICT_EQUAL'): tot[nm + ' entering'] += 1
        if v(a).startswith('STRICT_EQUAL') and not v(b).startswith('STRICT_EQUAL'): tot[nm + ' LEAVING'] += 1
        if a.get('rc') != b.get('rc'): tot[nm + ' rc changed'] += 1
        if a.get('cmplines') != b.get('cmplines'): tot[nm + ' cmplines changed'] += 1
print(' '.join(f'{k}={n}' for k, n in sorted(tot.items())))
