#!/usr/bin/env python3
# (v11u256) vgridsum.py <vgrid.txt>: per case-view the pristine, law and fix verdicts; VOFF must equal the law's
# bytes and UOFF pristine's; then the totals (fix against pristine and against the law).
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split(); d = dict(x.split('=', 1) for x in f[3:] if '=' in x); d['raw'] = ' '.join(f[3:]); rows[f[1]][f[0]] = d
tot = collections.Counter()
for cv in sorted(rows):
    r = rows[cv]; P, L, X, VO, UO = (r.get(k, {}) for k in ('P', 'L', 'FIX', 'VOFF', 'UOFF'))
    v = lambda d: d.get('strict', d.get('raw', '?'))
    flags = []
    if VO.get('md5') != L.get('md5'): flags.append('VOFF!=L')
    if UO.get('md5') != P.get('md5'): flags.append('UOFF!=P')
    if X.get('md5') != L.get('md5'): flags.append('fix-moves-vs-law')
    if X.get('md5') != P.get('md5'): flags.append('fix-moves-vs-P')
    rc = 'rc=%s/%s/%s' % (P.get('rc'), L.get('rc'), X.get('rc'))
    print(f'{cv:34s} P={v(P):28s} L={v(L):28s} FIX={v(X):28s} {rc} {" ".join(flags)}')
    tot['case-views'] += 1
    for k in flags: tot[k] += 1
    for nm, a, b in (('P->FIX', P, X), ('L->FIX', L, X), ('P->L', P, L)):
        if v(b).startswith('STRICT_EQUAL') and not v(a).startswith('STRICT_EQUAL'): tot[nm + ' entering'] += 1
        if v(a).startswith('STRICT_EQUAL') and not v(b).startswith('STRICT_EQUAL'): tot[nm + ' LEAVING'] += 1
    if len({P.get('rc'), L.get('rc'), X.get('rc')}) > 1: tot['rc differs'] += 1
    if len({P.get('cmplines'), L.get('cmplines'), X.get('cmplines')}) > 1: tot['cmplines differs'] += 1
print(' '.join(f'{k}={n}' for k, n in sorted(tot.items())))
