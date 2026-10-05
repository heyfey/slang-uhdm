#!/usr/bin/env python3
# v11u245: fixsum.py <grid.txt> <gridfix.txt>: per case-view law -> fix verdicts; fix + R11V245_OFF == law,
# fix + R11U245_OFF == pristine, per-switch reverts.  Reads only the grid lines (no database).
import sys, collections
rows = collections.defaultdict(dict)
for f in sys.argv[1:3]:
    for l in open(f):
        x = l.split(); rows[x[0]][x[1]] = dict(y.split('=', 1) for y in x[2:] if '=' in y)
voff = uoff = mv = ent = lev = 0; sw = collections.Counter()
for c, r in sorted(rows.items()):
    L, F = r['law'], r['fix']
    voff += r['fixVOFF']['md5'] == L['md5']; uoff += r['fixUOFF']['md5'] == r['pristine']['md5']
    for s in [k for k in r if k.startswith('fix-')]: sw[s[4:]] += r[s]['md5'] != F['md5']
    le = 'STRICT_EQUAL' in L.get('strict', ''); fe = 'STRICT_EQUAL' in F.get('strict', '')
    ent += fe and not le; lev += le and not fe
    if F['md5'] != L['md5']:
        mv += 1; print(f"| {c} | {L.get('strict')} cmp {L.get('cmplines')} | {F.get('strict')} cmp {F.get('cmplines')} rc {F.get('rc')} |")
print(f'case-views {len(rows)}; fix+R11V245_OFF == law {voff}; fix+R11U245_OFF == pristine {uoff}; moved vs law {mv}; '
      f'entering STRICT_EQUAL {ent}; leaving {lev}; per-switch reverts {dict(sw)}')
