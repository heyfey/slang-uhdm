#!/usr/bin/env python3
"""lawsum.py <grid_def.txt> <grid_el.txt> <fieldscore.txt>: per law, the verdict counts of its cells (grid.py RESULT
lines, both modes) and the field-level reading (fieldscore.py) of the same cells; per case the ON and ALLOFF strict
verdicts.  Markdown tables for the README."""
import re, sys, collections
g = {}
for mode, p in (('d', sys.argv[1]), ('e', sys.argv[2])):
    for l in open(p):
        m = re.match(r'\s+(\S+) (\S+) (?:cmp=\S+ cmplines=(\d+) strict=(\S+)|(\S+)) rc=(\d+)', l)
        if m:
            case, tag = m.group(1), m.group(2)
            v = m.group(4) or m.group(5)
            if v and v.startswith('STRICT_EQUAL'): v = 'EQ'
            elif v and v.startswith('STRICT_NOTEQUAL_'): v = v[16:]
            elif v and 'stage1' in v: v = 'S1'
            if m.group(3) and m.group(3) != '0': v = f'S1({m.group(3)})'
            g[(case, tag)] = (v, m.group(6))
res = collections.defaultdict(collections.Counter); cases = collections.defaultdict(set)
for p in sys.argv[1:3]:
    for l in open(p):
        if l.startswith('RESULT ') and not l.startswith('RESULT CRASH'):
            f = l.split()
            if len(f) < 4: continue
            res[f[2]][f[3]] += 1; cases[f[2]].add(re.sub(r'_el$', '', f[1]))
fs = collections.defaultdict(collections.Counter)
for l in open(sys.argv[3]):
    f = l.split()
    if f[1].startswith('off_'): fs[f[1][4:]][f[2]] += 1
for law in sorted(res):
    if law.startswith('LANDING') or law in ('ALLOFF', 'ALLOFF==PRE'): continue
    print(f'| § {law} | {len(cases[law])} | ' + ', '.join(f'{k} {v}' for k, v in sorted(res[law].items())) + ' | ' + ', '.join(f'{k} {v}' for k, v in sorted(fs[law].items())) + ' |')
print()
print('| case | ON d | ALLOFF d | ON el | ALLOFF el | rc (all states) |')
print('|---|---|---|---|---|---|')
for case in sorted({c for c, t in g if not c.endswith('_el')}):
    on = g.get((case, 'on'), ('-', ''))[0]; al = g.get((case, 'alloff'), ('-', ''))[0]
    oe = g.get((case + '_el', 'on'), ('-', ''))[0]; ae = g.get((case + '_el', 'alloff'), ('-', ''))[0]
    rcs = sorted({r for (c, t), (v, r) in g.items() if c in (case, case + '_el') and t != 'pre'})
    print(f'| {case} | {on} | {al} | {oe} | {ae} | {",".join(rcs)} |')
