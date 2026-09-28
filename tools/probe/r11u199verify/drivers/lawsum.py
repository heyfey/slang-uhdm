#!/usr/bin/env python3
"""lawsum.py <grid default> <grid elabuhdm> <recaway2> <dumpaway2>: per law (each against its own switch), the cases
naming it, the grid reading tally over both views, and the cells the chain-keyed record judge (recaway2) or the
dump judge (dumpaway2) reads AWAY (golden-agreeing records/lines the OFF state had and ON lost)."""
import re, sys, collections
T = collections.defaultdict(collections.Counter); C = collections.defaultdict(set); away = collections.defaultdict(list)
for p in sys.argv[1:3]:
    for l in open(p):
        m = re.match(r'RESULT (\S+) (\S+) (\S+)', l)
        if not m or m.group(2) in ('ALLOFF', 'WIDE') or m.group(2).startswith(('LANDING', 'PAIR:', 'EXTRA:')): continue
        T[m.group(2)][m.group(3)] += 1; C[m.group(2)].add(re.sub(r'_el$', '', m.group(1)))
for p, key in ((sys.argv[3], 'away'), (sys.argv[4], 'lost')):
    for l in open(p):
        f = l.split()
        if len(f) < 3 or not f[1].startswith('off_'): continue
        n = int(f[2].split('=')[1])
        if n: away[f[1][4:]].append(f'{f[0]}:{key}={n}')
for law in sorted(T):
    print(f"{law} | cases {len(C[law])} | " + ' '.join(f'{k}={v}' for k, v in sorted(T[law].items())) + (' | AWAY-judges: ' + ' '.join(away[law]) if away[law] else ''))
