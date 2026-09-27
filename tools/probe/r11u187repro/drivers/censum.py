#!/usr/bin/env python3
"""r11u187 (after r11u183dec/drivers/censum.py): summarize the firing census trace dir: one line per database that
fired any law, with law counts (the PREDICTED movers).  A trace file may hold several `OUT` blocks (pid reuse):
each block is attributed to its own database.  usage: censum.py <trace dir> <census workdir>"""
import sys, os, collections
tr, wd = sys.argv[1:3]
rows = collections.defaultdict(collections.Counter)
for f in sorted(os.listdir(tr)):
    key = None
    for l in open(os.path.join(tr, f)).read().splitlines():
        if l.startswith('OUT '):
            rel = os.path.relpath(l[4:], wd).split('/')
            if rel[0] == 'probe':
                key = 'probe/' + rel[-1].rsplit('.uhdm', 1)[0]
            elif len(rel) >= 3:
                key = f"{rel[0]}/{rel[1]}/{rel[2].rsplit('-', 1)[0]}"
            else:
                key = l[4:]
            continue
        if key: rows[key][l] += 1
for k in sorted(rows):
    print(k, ' '.join(f'{l}:{n}' for l, n in sorted(rows[k].items())))
print('DATABASES', len(rows), 'corpus', sum(1 for k in rows if not k.startswith('probe/')), 'probe', sum(1 for k in rows if k.startswith('probe/')))
