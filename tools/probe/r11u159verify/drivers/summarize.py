#!/usr/bin/env python3
"""summarize.py <grid_default.txt> <grid_el.txt> <ds_ON> <ds_OWN> <ds_ALLOFF> <fix_vs_on>: one table per law:
case | default: on verdict / off verdict / score | --elabuhdm: score | downstream on / own-off | fix."""
import re, sys, collections
gd, ge, dson, dsown, dsall, fx = sys.argv[1:7]
def verdicts(p):
    v = {}; r = collections.defaultdict(dict)
    for l in open(p):
        m = re.match(r'\s+(\S+) (\S+) (?:cmp=\d+ cmplines=(\d+) strict=(\S+)|(SURELOG_FAIL|SLANG_FAIL))', l)
        if m:
            case, tag = m.group(1), m.group(2)
            s = m.group(4) or m.group(5)
            s = s.replace('STRICT_EQUAL_', 'EQ').replace('STRICT_NOTEQUAL_', 'SN:').replace('NOT_EQUAL_stage1', f'S1({m.group(3)})').replace('_objects', '')
            v[(case, tag)] = s
        m = re.match(r'RESULT (\S+) (\S+) (\S+)(.*)', l)
        if m: r[m.group(1)][m.group(2)] = (m.group(3), m.group(4).strip())
    return v, r
vd, rd = verdicts(gd); ve, re_ = verdicts(ge)
def ds(p):
    d = {}
    for l in open(p):
        f = [x.strip() for x in l.split('|')]
        if len(f) >= 6: d[f[1]] = f[2] + ('' if f[5] in ('-', '') else f'({f[5]})')
    return d
don, down, dall = ds(dson), ds(dsown), ds(dsall)
fix = {}
for l in open(fx):
    c, s = l.split(None, 1); fix[c] = s.strip()
bylaw = collections.defaultdict(list)
for case, laws in rd.items():
    for law, (sc, det) in laws.items():
        if law == 'ALLOFF': continue
        bylaw[law].append(case)
for law in sorted(bylaw):
    print(f'\n### § {law}\n')
    print('| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |')
    print('|---|---|---|---|---|---|---|')
    for case in sorted(bylaw[law]):
        on = vd.get((case, 'on'), '?'); off = vd.get((case, 'off_' + law), '?')
        sc = rd[case][law][0]; sce = re_.get(case + '_el', {}).get(law, ('-',))[0]
        d1 = don.get(case, '-'); d2 = down.get(case, '-')
        fxs = fix.get(case, '-').replace('SAME-AS-ON', 'as on')
        print(f'| `{case}` | {on} | {off} | {sc} | {sce} | {d1} / {d2} | {fxs} |')
