#!/usr/bin/env python3
# v11u248: vgridsum.py <vgrid.txt>: per case-view the verdict on pristine, law and fix; counts: entering / leaving
# STRICT_EQUAL (law and fix against pristine), R11U248_OFF on the fix == pristine bytes, R11V248_OFF on the fix ==
# law bytes, which switches revert the fix's bytes, uhdm-cmp line counts rising, non-zero exit codes.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    d = dict(x.split('=', 1) for x in f[2:] if '=' in x)
    rows[f[0]][f[1]] = (d.get('strict', f[2]), d.get('md5'), int(d.get('cmplines', -1)), d.get('rc'))
E = lambda v: v[0].startswith('STRICT_EQUAL')
c = collections.Counter(); nz = []; tab = []
for cv, r in sorted(rows.items()):
    p, L, X = r['pristine'], r['law'], r['fix']
    c['n'] += 1
    c['law_enter'] += E(L) and not E(p); c['law_leave'] += E(p) and not E(L)
    c['fix_enter'] += E(X) and not E(p); c['fix_leave'] += E(p) and not E(X)
    c['off_pristine'] += r['fixOFF'][1] == p[1]; c['voff_law'] += r['fixVOFF'][1] == L[1]
    c['rise'] += X[2] > p[2] or L[2] > p[2]
    nz += [f'{cv} {t} rc={v[3]}' for t, v in r.items() if v[3] != '0']
    sw = [t.replace('fix-', '').replace('_OFF', '') for t, v in r.items() if t.startswith('fix-') and v[1] != X[1]]
    tab.append(f'| {cv} | {p[0]} | {L[0]} | {X[0]} | {"moves" if p[1] != X[1] else "-"} | {"moves" if L[1] != X[1] else "-"} | {" ".join(sw) or "-"} |')
n = c['n']
print(f"case-views {n}; law: entering STRICT_EQUAL {c['law_enter']}, leaving {c['law_leave']}; fix: entering {c['fix_enter']}, leaving {c['fix_leave']}; "
      f"fix+R11U248_OFF pristine bytes {c['off_pristine']}/{n}; fix+R11V248_OFF law bytes {c['voff_law']}/{n}; uhdm-cmp count rising {c['rise']}; non-zero exits {len(nz)}")
for x in nz: print('  ' + x)
print('| case-view | pristine | law | fix | fix vs pristine | fix vs law | switches reverting the fix |\n|---|---|---|---|---|---|---|')
print('\n'.join(tab))
