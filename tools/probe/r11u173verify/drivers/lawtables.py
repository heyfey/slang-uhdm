#!/usr/bin/env python3
"""lawtables.py <grid_default.txt> <grid_elabuhdm.txt> <downstream_ON> <downstream_ALLOFF>: one markdown table per law
(the README's section 3): per case the strict verdict with the law's own switch off, with both landings off
(pristine for these laws), with every law on, grid.py's classification of ON against the law's own switch (default
mode, then --elabuhdm mode), and the downstream verdict both landings off -> on."""
import sys, re, collections
def load(p):
    ver, res = {}, collections.defaultdict(dict)
    for l in open(p):
        m = re.match(r'\s+(\S+) (\S+) (?:cmp=\S+ cmplines=\S+ strict=(\S+)|(SURELOG_FAIL|SLANG_FAIL))', l)
        if m:
            s = m.group(3) or m.group(4)
            s = 'EQ' if s.startswith('STRICT_EQUAL') else 'S1' if 'stage1' in s else s.replace('STRICT_NOTEQUAL_', '')
            ver[(re.sub(r'_el$', '', m.group(1)), m.group(2))] = s; continue
        if l.startswith('RESULT'):
            f = l.split(' ', 4); res[re.sub(r'_el$', '', f[1])][f[2]] = f[3].strip() if len(f) > 3 else '?'
    return ver, res
vd, rd = load(sys.argv[1]); ve, re_ = load(sys.argv[2])
def ds(p):
    d = {}
    for l in open(p):
        f = [x.strip() for x in l.split('|')]
        if len(f) > 2: d[f[1]] = f[2]
    return d
don, doff = ds(sys.argv[3]), ds(sys.argv[4])
bylaw = collections.defaultdict(list)
for case, d in rd.items():
    for law in d:
        if not law.startswith(('LANDING', 'PAIR', 'ALLOFF')): bylaw[law].append(case)
tot = collections.Counter()
for law in sorted(bylaw):
    cs = sorted(bylaw[law]); c = collections.Counter(rd[x][law] for x in cs)
    print(f'#### § {law} ({len(cs)} cases: ' + ', '.join(f'{k} {v}' for k, v in sorted(c.items())) + ')\n')
    print('| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |')
    print('|---|---|---|---|---|---|---|---|')
    for x in cs:
        t = 'off_' + law
        dsv = f'{doff.get(x, "-")} -> {don.get(x, "-")}' if x in don else '-'
        print(f'| {x} | {vd.get((x, t), "?")} | {vd.get((x, "alloff"), "?")} | {vd.get((x, "on"), "?")} | {rd[x][law]} | {ve.get((x, "on"), "?")} | {re_.get(x, {}).get(law, "?")} | {dsv} |')
        tot[rd[x][law]] += 1; tot['el:' + re_.get(x, {}).get(law, '?')] += 1
    print()
print('totals:', dict(sorted(tot.items())))
