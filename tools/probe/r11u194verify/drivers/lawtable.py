#!/usr/bin/env python3
# (r11u194: copied from r11u190verify/drivers, paths renamed; the landings under test are passes 184 and 186.)
"""lawtable.py <gridD.all> <gridE.all> <recaway2.txt> <dumpaway.txt> [dscase.txt]: per law, over the cases whose first
line names it and both modes: cells, UNFIRED cells, strict ON vs the law's own switch (EQ gained / kept / lost),
uhdm-cmp line counts (up / same / down), strict-record judge (chain-keyed away cells), uhdm-dump judge (lost cells),
downstream verdict changes (r11u182)."""
import sys, re, collections
runs = collections.defaultdict(dict); res = collections.defaultdict(dict)
for p in sys.argv[1:3]:
    for l in open(p):
        m = re.match(r'\s+(\S+) (\S+) cmp=\S+ cmplines=(\d+) strict=(\S+) rc=(\d+)', l)
        if m: runs[m.group(1)][m.group(2)] = (int(m.group(3)), m.group(4), int(m.group(5)))
        m = re.match(r'RESULT (\S+) (\S+) (\S+)', l)
        if m: res[m.group(1)][m.group(2)] = m.group(3)
ra = collections.defaultdict(dict)
for l in open(sys.argv[3]):
    f = l.split()
    if len(f) >= 4: ra[f[0]][f[1]] = int(f[2].split('=')[1])
da = collections.defaultdict(dict)
for l in open(sys.argv[4]):
    f = l.split()
    if len(f) >= 4: da[f[0]][f[1]] = int(f[2].split('=')[1])
ds = collections.defaultdict(dict)
if len(sys.argv) > 5:
    for l in open(sys.argv[5]):
        f = [x.strip() for x in l.split('|')]
        if len(f) > 2: ds[f[1]][f[0]] = f[2]
T = collections.defaultdict(collections.Counter)
for c, laws in res.items():
    for law, v in laws.items():
        if law in ('ALLOFF', 'ALLOFF==PRE') or law.startswith(('LANDING', 'PAIR:')): continue
        tag = 'off_' + law; t = T[law]; t['cells'] += 1
        if v == 'UNFIRED': t['unfired'] += 1; continue
        on = runs[c].get('on'); off = runs[c].get(tag)
        if not on or not off: continue
        eqon, eqoff = on[1].startswith('STRICT_EQUAL'), off[1].startswith('STRICT_EQUAL')
        t['strict:' + ('gained' if eqon and not eqoff else 'kept' if eqon else 'LOST' if eqoff else 'ne-both')] += 1
        t['cmp:' + ('UP' if on[0] > off[0] else 'down' if on[0] < off[0] else 'same')] += 1
        if on[2] in (134, 139) and off[2] not in (134, 139): t['CRASH'] += 1
        if ra[c].get(tag, 0): t['rec-away-cells'] += 1
        if da[c].get(tag, 0): t['dump-lost-cells'] += 1
        base = c[:-3] if c.endswith('_el') else c
        if base in ds and not c.endswith('_el'):
            t['ds:' + ('same' if ds[base].get('ON') == ds[base].get('OWN') else f"{ds[base].get('OWN')}->{ds[base].get('ON')}")] += 1
for law in sorted(T):
    print(law, ' '.join(f'{k}={v}' for k, v in sorted(T[law].items())))
