#!/usr/bin/env python3
"""summarize.py <grid_default.txt> <grid_el.txt> <ds_ON> <ds_OWN> <ds_ALLOFF> [fixgrid]: one table per law:
case | default: on verdict / own-switch-off verdict / score | --elabuhdm score | downstream on / own-off / alloff | fix."""
import re, sys, collections
gd, ge, dson, dsown, dsall = sys.argv[1:6]
fx = sys.argv[6] if len(sys.argv) > 6 else None
def verdicts(p):
    v = {}; r = collections.defaultdict(dict)
    for l in open(p):
        m = re.match(r'\s+(\S+) (\S+) (?:cmp=\d+ cmplines=(\d+) strict=(\S+)|(SURELOG_FAIL|SLANG_FAIL))', l)
        if m:
            s = m.group(4) or m.group(5)
            s = re.sub(r'STRICT_EQUAL_\d+_objects', 'EQ', s).replace('STRICT_NOTEQUAL_', 'SN:').replace('NOT_EQUAL_stage1', f'S1({m.group(3)})')
            v[(m.group(1), m.group(2))] = s
        m = re.match(r'RESULT (\S+) (\S+) (\S+)(.*)', l)
        if m: r[m.group(1)][m.group(2)] = (m.group(3), m.group(4).strip())
        m = re.match(r'RESULT (\S+) NOGOLD', l)
        if m: r[m.group(1)]['NOGOLD'] = ('NOGOLD', '')
    return v, r
vd, rd = verdicts(gd); ve, re_ = verdicts(ge)
def ds(p):
    d = {}
    for l in open(p):
        f = [x.strip() for x in l.split('|')]
        if len(f) >= 6: d[f[1]] = f[2]
    return d
don, down, dall = ds(dson), ds(dsown), ds(dsall)
fix = {}
if fx:
    for l in open(fx):
        p = l.split()
        if len(p) >= 2: fix[p[0]] = ' '.join(p[1:])
bylaw = collections.defaultdict(list)
for case, laws in rd.items():
    for law in laws:
        if law in ('ALLOFF',): continue
        bylaw[law].append(case)
tally = collections.defaultdict(collections.Counter)
for law in sorted(bylaw):
    print(f'\n### § {law}\n')
    print('| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off |' + (' fix |' if fx else ''))
    print('|---|---|---|---|---|---|' + ('---|' if fx else ''))
    for case in sorted(bylaw[law]):
        if law == 'NOGOLD':
            print(f'| `{case}` | Surelog writes no database (SURELOG_FAIL) | | | | {don.get(case, "-")} |' + (' |' if fx else '')); continue
        on = vd.get((case, 'on'), '?'); off = vd.get((case, 'off_' + law), '?')
        sc = rd[case][law][0]; sce = re_.get(case + '_el', {}).get(law, ('-',))[0]
        tally[law][sc] += 1
        d = f'{don.get(case, "-")} / {down.get(case, "-")} / {dall.get(case, "-")}'
        print(f'| `{case}` | {on} | {off} | {sc} | {sce} | {d} |' + (f' {fix.get(case, "-")} |' if fx else ''))
print('\n### Tally per law (default mode)\n')
print('| law | cases | ' + ' | '.join(['TOWARD', 'STAGE1-CLOSER', 'STAGE1-SAME', 'BYTES-ONLY', 'UNFIRED', 'AWAY/MIXED/STAGE1-AWAY']) + ' |')
print('|---|---|---|---|---|---|---|---|')
for law in sorted(tally):
    t = tally[law]
    print(f'| § {law} | {sum(t.values())} | {t["TOWARD"]} | {t["STAGE1-CLOSER"]} | {t["STAGE1-SAME"]} | {t["BYTES-ONLY"]} | {t["UNFIRED"]} | {t["AWAY"] + t["MIXED"] + t["STAGE1-AWAY"]} |')
