#!/usr/bin/env python3
"""lawcases.py <grid_def.txt> <grid_el.txt>: per law, the cases whose OWN switch moves bytes (the law fired), with the
grid reading in each mode (d / e) and the case's ON verdict; the cases where it never fired are counted.  Markdown."""
import re, sys, collections
res = collections.defaultdict(dict); onv = {}
for mode, p in (('d', sys.argv[1]), ('e', sys.argv[2])):
    for l in open(p):
        m = re.match(r'\s+(\S+) on (?:cmp=\S+ cmplines=(\d+) strict=(\S+)|(\S+)) rc=', l)
        if m:
            v = m.group(3) or m.group(4)
            v = 'EQ' if v.startswith('STRICT_EQUAL') else v.replace('STRICT_NOTEQUAL_', '') if v.startswith('STRICT_NOTEQUAL') else ('S1' if 'stage1' in v else v)
            onv[(re.sub(r'_el$', '', m.group(1)), mode)] = v
        if l.startswith('RESULT ') and len(l.split()) >= 4:
            f = l.split(); c = re.sub(r'_el$', '', f[1]); md = 'e' if f[1].endswith('_el') else 'd'
            if f[2].startswith('LANDING') or f[2] in ('ALLOFF', 'ALLOFF==PRE', 'CRASH-OR-TIMEOUT'): continue
            res[f[2]][(c, md)] = f[3]
for law in sorted(res):
    cells = res[law]; cases = sorted({c for c, _ in cells})
    fired = [c for c in cases if any(cells.get((c, m), 'UNFIRED') != 'UNFIRED' for m in 'de')]
    print(f'#### § {law}: {len(cases)} cases, fired on {len(fired)}')
    print()
    if fired:
        print('| case | law off -> on (d / e) | ON verdict (d / e) |'); print('|---|---|---|')
        for c in fired:
            print(f'| {c} | {cells.get((c, "d"), "-")} / {cells.get((c, "e"), "-")} | {onv.get((c, "d"), "-")} / {onv.get((c, "e"), "-")} |')
        print()
    nf = [c for c in cases if c not in fired]
    if nf: print('unfired (same bytes both modes): ' + ', '.join(nf)); print()
