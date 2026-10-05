#!/usr/bin/env python3
# gridsum.py <grid.txt>: per case-view the verdict on pristine, law, law+R11U248_OFF and each switch; counts:
# entering / leaving STRICT_EQUAL against pristine, R11U248_OFF == pristine bytes, each switch reverting its own case,
# uhdm-cmp line counts rising, non-zero exit codes.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    d = dict(x.split('=', 1) for x in f[2:] if '=' in x)
    rows[f[0]][f[1]] = (d.get('strict', f[2]), d.get('md5'), int(d.get('cmplines', -1)), d.get('rc'))
enter = leave = offpr = rise = 0; nz = []; table = []
for cv, r in sorted(rows.items()):
    p, L, o = r.get('pristine'), r.get('law'), r.get('lawOFF')
    if not (p and L): continue
    pe, le = p[0].startswith('STRICT_EQUAL'), L[0].startswith('STRICT_EQUAL')
    enter += (le and not pe); leave += (pe and not le)
    offpr += bool(o and o[1] == p[1])
    rise += L[2] > p[2]
    nz += [f'{cv} {t} rc={v[3]}' for t, v in r.items() if v[3] != '0']
    sw = [t.replace('law-R11U248_', '').replace('_OFF', '') for t, v in r.items() if t.startswith('law-') and v[1] != L[1]]
    table.append(f'| {cv} | {p[0]} | {L[0]} | {"moves" if p[1] != L[1] else "-"} | {" ".join(sw) or "-"} |')
print(f'case-views {len(table)}; entering STRICT_EQUAL {enter}, leaving {leave}; R11U248_OFF pristine bytes {offpr}/{len(table)}; uhdm-cmp count rising {rise}; non-zero exits {len(nz)}')
for x in nz: print('  ' + x)
print('| case-view | pristine | law | bytes | switches that revert it |\n|---|---|---|---|---|')
print('\n'.join(table))
