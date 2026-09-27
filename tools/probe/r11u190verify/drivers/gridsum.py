#!/usr/bin/env python3
# (r11u190: copied from r11u185verify/drivers, paths renamed; the landings under test are passes 180 and 181.)
"""gridsum.py <grid all.txt> [fieldscore.txt]: one line per case: the ON strict verdict, each named law's OFF strict
verdict and grid reading, ALLOFF, and PREOFF==PRE (r11u182)."""
import sys, re, collections
L = open(sys.argv[1]).read().splitlines()
fs = collections.defaultdict(dict)
if len(sys.argv) > 2:
    for l in open(sys.argv[2]):
        f = l.split()
        if len(f) >= 3: fs[f[0]][f[1]] = f[2]
runs = collections.defaultdict(dict); res = collections.defaultdict(list); pre = {}
for l in L:
    m = re.match(r'\s+(\S+) (\S+) cmp=\S+ cmplines=(\d+) strict=(\S+) rc=(\d+)', l)
    if m: runs[m.group(1)][m.group(2)] = (m.group(4).replace('STRICT_', '').replace('_objects', ''), m.group(3), m.group(5)); continue
    m = re.match(r'\s+(\S+) (\S+) (SURELOG_FAIL|SLANG_FAIL) rc=(\d+)', l)
    if m: runs[m.group(1)][m.group(2)] = (m.group(3), '-', m.group(4)); continue
    m = re.match(r'RESULT (\S+) (\S+) (\S+)', l)
    if m:
        if m.group(2) == 'ALLOFF==PRE': pre[m.group(1)] = m.group(3)
        else: res[m.group(1)].append((m.group(2), m.group(3)))
for c in sorted(runs):
    r = runs[c]; on = r.get('on', ('?',))
    parts = [f'ON={on[0]}(cmp{on[1]},rc{on[2]})']
    for law, v in res[c]:
        tag = {'ALLOFF': 'alloff'}.get(law, 'offL' + law[7:] if law.startswith('LANDING') else ('off2_' + law[5:].replace('+', '_') if law.startswith('PAIR:') else 'off_' + law))
        o = r.get(tag, ('?',))
        f = fs.get(c, {}).get(tag, '')
        parts.append(f'{law}:{v}{"/" + f if f and f != "SKIP" else ""}[off={o[0]}]')
    parts.append('PRE=' + pre.get(c, '?'))
    print(c, ' '.join(parts))
