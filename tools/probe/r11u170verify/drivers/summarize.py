#!/usr/bin/env python3
"""summarize.py <grid_default.txt> <grid_el.txt>: per law, the fresh cases and the ON-vs-own-switch verdict in
both modes (grid.py RESULT lines), plus the landing/pair/ALLOFF rows and ALLOFF==PRE counts."""
import sys, re, collections
per = collections.defaultdict(lambda: collections.defaultdict(list)); pre = collections.Counter()
for mode, p in (('def', sys.argv[1]), ('el', sys.argv[2])):
    for l in open(p):
        if not l.startswith('RESULT'): continue
        f = l.split(); case = f[1].replace('_el', ''); law = f[2]
        if law == 'ALLOFF==PRE': pre[(mode, f[3])] += 1; continue
        if law == 'NOGOLD': per['NOGOLD'][mode].append(case + ':NOGOLD'); continue
        v = f[3] if len(f) > 3 else '?'
        per[law][mode].append(f'{case}:{v}')
for law in sorted(per):
    if law.startswith(('LANDING', 'PAIR', 'ALLOFF')): continue
    d = per[law]
    cnt = {m: collections.Counter(x.split(':')[1] for x in d[m]) for m in d}
    print(f'{law}: cases={len(d.get("def", []))} | def ' + ' '.join(f'{k}={v}' for k, v in sorted(cnt.get('def', {}).items())) +
          ' | el ' + ' '.join(f'{k}={v}' for k, v in sorted(cnt.get('el', {}).items())))
    print('   ' + ' '.join(sorted(set(x.split(':')[0] for x in d.get('def', [])))))
for law in sorted(per):
    if law.startswith(('LANDING', 'PAIR', 'ALLOFF')):
        d = per[law]; cnt = {m: collections.Counter(x.split(':')[1] for x in d[m]) for m in d}
        print(f'{law}: def ' + ' '.join(f'{k}={v}' for k, v in sorted(cnt.get('def', {}).items())) + ' | el ' + ' '.join(f'{k}={v}' for k, v in sorted(cnt.get('el', {}).items())))
print('ALLOFF==PRE:', dict(pre))
