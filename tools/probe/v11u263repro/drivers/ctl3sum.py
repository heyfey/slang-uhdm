#!/usr/bin/env python3
# (v11u263) ctl3sum.py <controls3 output>...: per case-view the pristine / law / fix lines; counts the law's and the
# fix's movers against pristine, the fix's movers against the law, entries into and departures from STRICT_EQUAL,
# exit-code and uhdm-cmp line-count changes; lists every mover.
import sys, collections
R = collections.defaultdict(dict)
for fn in sys.argv[1:]:
    for l in open(fn):
        f = l.split()
        if len(f) < 3: continue
        kv = dict(x.split('=', 1) for x in f[2:] if '=' in x)
        R[f[0]][f[1]] = (kv.get('md5', f[2]), kv.get('strict', f[2]), kv.get('rc', '?'), kv.get('cmplines', '?'))
eq = lambda v: v[1].startswith('STRICT_EQUAL')
n = 0; c = collections.Counter(); out = []
for cv in sorted(R):
    r = R[cv]
    if not all(k in r for k in ('pristine', 'law', 'fix')): c['incomplete'] += 1; continue
    n += 1; P, L, F = r['pristine'], r['law'], r['fix']
    for tag, X in (('law', L), ('fix', F)):
        if X[0] != P[0]: c[tag + '_moving'] += 1; out.append(f'{tag.upper()}-MOVER {cv} {P[1]} -> {X[1]} cmplines {P[3]}->{X[3]}')
        if eq(X) and not eq(P): c[tag + '_entering'] += 1
        if eq(P) and not eq(X): c[tag + '_leaving'] += 1
        if X[2] != P[2]: c[tag + '_rc_changed'] += 1
        if X[3] != P[3]: c[tag + '_cmplines_changed'] += 1
    if F[0] != L[0]: c['fix_vs_law_moving'] += 1; out.append(f'FIX-VS-LAW {cv} {L[1]} -> {F[1]}')
    for X in (P, L, F):
        if X[2] != '0': c['rc_nonzero_lines'] += 1
print('case-views=%d ' % n + ' '.join(f'{k}={v}' for k, v in sorted(c.items())))
print('\n'.join(out))
