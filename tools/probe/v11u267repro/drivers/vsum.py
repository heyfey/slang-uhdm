#!/usr/bin/env python3
# v11u267 vsum.py <vgrid out>...: summary of drivers/vgrid.sh lines: case-views, movers P->L, P->F, L->F (entering /
# leaving STRICT_EQUAL), R11U267_OFF == pristine, R11V267_OFF == law, the switch that moves each mover alone, rc != 0.
# Reads only the grid text (no database).
import sys, collections
d = collections.defaultdict(dict); bad = 0
for fn in sys.argv[1:]:
    for l in open(fn):
        f = l.split(); bad += 'rc=0' not in l
        d[f[1]][f[0]] = {x.split('=', 1)[0]: x.split('=', 1)[1] for x in f[3:] if '=' in x}
print('case-views', len(d), 'rc!=0 lines', bad)
for a, b in [('P', 'L'), ('P', 'F'), ('L', 'F')]:
    mv = [k for k, r in d.items() if r[a]['md5'] != r[b]['md5']]
    ent = sum('STRICT_EQUAL' in d[k][b]['strict'] and 'STRICT_EQUAL' not in d[k][a]['strict'] for k in mv)
    lv = sum('STRICT_EQUAL' in d[k][a]['strict'] and 'STRICT_EQUAL' not in d[k][b]['strict'] for k in mv)
    print(a, '->', b, 'moving', len(mv), 'entering', ent, 'leaving', lv)
print('R11U267_OFF==P', sum(r['OFF']['md5'] == r['P']['md5'] for r in d.values()),
      'R11V267_OFF==L', sum(r['VOFF']['md5'] == r['L']['md5'] for r in d.values()))
cnt = collections.Counter(); multi = []
for k, r in d.items():
    if r['P']['md5'] != r['F']['md5'] or r['L']['md5'] != r['F']['md5']:
        s = [x for x in r if x.startswith('R11') and r[x]['md5'] != r['F']['md5']]
        cnt.update(s) if len(s) == 1 else multi.append((k, s))
print('movers by switch', dict(cnt), 'not by exactly one switch', multi)
