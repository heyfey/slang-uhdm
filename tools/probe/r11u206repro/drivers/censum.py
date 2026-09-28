#!/usr/bin/env python3
"""r11u206: summarize the firing census trace dir: one line per row-mode / probe case that fired any law, with law
counts (the law name is each trace line's first token).
usage: censum.py <trace dir> <census workdir> -> stdout '<corpus>/<mode>/<test> law:n ...' (the PREDICTED movers)"""
import sys, os, collections
tr, wd = sys.argv[1:3]
rows = collections.defaultdict(collections.Counter)
for f in os.listdir(tr):
    lines = open(os.path.join(tr, f), errors='replace').read().splitlines()
    if not lines or not lines[0].startswith('OUT '): continue
    out = lines[0][4:]
    rel = os.path.relpath(out, wd).split('/')
    if rel[0] in ('surelog', 'uhdm2rtlil') and len(rel) >= 3:
        key = f"{rel[0]}/{rel[1]}/{rel[2].rsplit('-',1)[0]}"
    else:
        key = os.path.relpath(out, wd)
    for l in lines[1:]:
        if l.startswith('OUT '): continue
        rows[key][l.split(' ', 1)[0]] += 1
for k in sorted(rows):
    print(k, ' '.join(f'{l}:{n}' for l, n in sorted(rows[k].items())))
print('ROWS', len(rows))
