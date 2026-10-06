#!/usr/bin/env python3
# (v11u254: copied from r11u254repro/drivers)
# r11u254 gridcensus.py <grid.txt>: the grid's census — R11U254_OFF against pristine (bytes), every switch's own movers
# (a case-view whose bytes differ between the law and the law with that switch off), and the pristine -> law verdict
# transitions (moving, entering STRICT_EQUAL, leaving, first-field changes, uhdm-cmp line-count changes, exit codes).
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split(); d = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    st = d.get('strict', f[3] if len(f) > 3 else '')
    rows[f[1]][f[0]] = (st, d.get('md5', st), d.get('rc', ''), d.get('cmplines', ''))
sw = sorted({c for r in rows.values() for c in r} - {'P', 'L', 'OFF'})
off = sum(1 for r in rows.values() if r['OFF'][1] == r['P'][1])
print(f'case-views {len(rows)}; R11U254_OFF = pristine bytes on {off} of {len(rows)}')
for s in sw:
    own = [cv for cv, r in rows.items() if r[s][1] != r['L'][1]]
    print(f'{s}: moves {len(own)} case-views')
mv = ent = lv = 0
for cv, r in sorted(rows.items()):
    P, L = r['P'], r['L']
    if P[2] != L[2]: print('EXIT', cv, P[2], L[2])
    if P[1] == L[1]: continue
    mv += 1
    if L[0].startswith('STRICT_EQUAL') and not P[0].startswith('STRICT_EQUAL'): ent += 1
    if P[0].startswith('STRICT_EQUAL') and not L[0].startswith('STRICT_EQUAL'): lv += 1; print('LEAVE', cv)
    if P[0] != L[0] and not L[0].startswith('STRICT_EQUAL'): print('CHANGE', cv, P[0], '->', L[0])
    if P[3] != L[3]: print('CMPLINES', cv, P[3], '->', L[3])
    owners = [s for s in sw if r[s][1] != L[1]]
    print('MOVER', cv, P[0], '->', L[0], 'owners=' + ','.join(o.replace('R11U254_', '').replace('_OFF', '') for o in owners))
print(f'moving {mv}, entering STRICT_EQUAL {ent}, leaving {lv}')
