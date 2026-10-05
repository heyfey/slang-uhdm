#!/usr/bin/env python3
# (v11u238) gridsum.py <grid.txt>: the grid table: per case-view the pristine / law / fix verdicts, and the switch checks
# (law + R11U238_OFF and fix + R11U238_OFF = pristine bytes, fix + R11V238_OFF = the law's bytes, each switch's movers).
import sys, collections
d = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    t = l.split()
    if len(t) < 3: continue
    md5 = [x for x in t if x.startswith('md5=')]; rc = [x for x in t if x.startswith('rc=')]
    st = [x for x in t if x.startswith('strict=')]; cl = [x for x in t if x.startswith('cmplines=')]
    d[t[0]][t[1]] = dict(md5=md5[0][4:] if md5 else '-', rc=rc[0][3:] if rc else '?', st=(st[0][7:] if st else t[2]), cl=cl[0][9:] if cl else '-')
def eq(v): return v['st'].startswith('STRICT_EQUAL')
def je(v): return v['st'].startswith('STRICT_')
rows = []; c = collections.Counter(); sw = collections.Counter()
for cv in sorted(d):
    m = d[cv]; p, L, F = m['pristine'], m['law'], m['fix']
    c['caseviews'] += 1
    c['nonzero_rc_any'] += any(v['rc'] != '0' for v in m.values())
    c['lawOFF_pristine'] += m['lawOFF']['md5'] == p['md5']
    c['fixOFF_pristine'] += m['fixOFF']['md5'] == p['md5']
    c['fixVOFF_law'] += m['fixVOFF']['md5'] == L['md5']
    for k, v in m.items():
        if k.startswith('law-') and v['md5'] != L['md5']: sw[k] += 1
        if k.startswith('fix-') and v['md5'] != F['md5']: sw[k] += 1
    for tag, x in (('law', L), ('fix', F)):
        c[f'{tag}_moved'] += x['md5'] != p['md5']
        c[f'{tag}_enter_STRICT_EQUAL'] += eq(x) and not eq(p)
        c[f'{tag}_leave_STRICT_EQUAL'] += eq(p) and not eq(x)
        c[f'{tag}_leave_judge_equal'] += je(p) and not je(x)
        c[f'{tag}_cmplines_changed'] += x['cl'] != p['cl']
    rows.append(f"{cv:30s} P {p['st']:28s} L {L['st']:28s} F {F['st']:28s} rc {p['rc']}/{L['rc']}/{F['rc']}")
print('\n'.join(rows)); print()
for k, v in c.items(): print(f'{k}: {v}')
for k, v in sorted(sw.items()): print(f'switch {k}: {v} case-views move')
