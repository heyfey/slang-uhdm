#!/usr/bin/env python3
"""r11u191: summarize the firing census trace dir: one line per row-mode that fired any law, with law counts.
usage: censum.py <trace dir> <census workdir> -> stdout 'corpus/mode/test law:n ...' (the PREDICTED movers)"""
import sys, os, collections, re
tr, wd = sys.argv[1:3]
rows = collections.defaultdict(collections.Counter)
for f in os.listdir(tr):
    lines = open(os.path.join(tr, f)).read().splitlines()
    if not lines or not lines[0].startswith('OUT '): continue
    out = lines[0][4:]
    rel = os.path.relpath(out, wd).split('/')
    key = f"{rel[0]}/{rel[1]}/{rel[2].rsplit('-',1)[0]}" if len(rel) >= 3 else out
    for l in lines[1:]:
        if l.startswith('OUT '): continue
        rows[key][l.split()[0]] += 1   # r11u211: the trace lines are <law> <detail>
for k in sorted(rows):
    print(k, ' '.join(f'{l}:{n}' for l, n in sorted(rows[k].items())))
print('ROWS', len(rows))
