#!/usr/bin/env python3
"""r11u207: summarize a firing-census trace dir (R11U207_TRACE files: first line `OUT <db>`, then one
law name per firing; one process may write several files, merged by OUT).  One line per database that fired a law:
`<key> law:n ...`, key = <corpus>/<mode>/<test> for a corpus row-mode, probe/<case> for a probe case (the PREDICTED
movers).  usage: censum.py <trace dir> <census workdir>"""
import sys, os, collections
tr, wd = sys.argv[1:3]
rows = collections.defaultdict(collections.Counter)
for f in os.listdir(tr):
    lines = open(os.path.join(tr, f)).read().splitlines()
    if not lines or not lines[0].startswith('OUT '):
        continue
    out = lines[0][4:]
    rel = os.path.relpath(out, wd).split('/')
    if rel[0] == 'probe':
        key = 'probe/' + rel[1][:-len('.uhdm')].replace('__', '/')
    elif len(rel) >= 3:
        key = f"{rel[0]}/{rel[1]}/{rel[2].rsplit('-', 1)[0]}"
    else:
        key = out
    for l in lines[1:]:
        if not l.startswith('OUT '):
            rows[key][l.split(' ', 1)[0]] += 1
for k in sorted(rows):
    print(k, ' '.join(f'{l}:{n}' for l, n in sorted(rows[k].items())))
print('ROWS', len(rows))
