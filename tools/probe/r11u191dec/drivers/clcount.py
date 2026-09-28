#!/usr/bin/env python3
"""r11u191: records per map-10 cluster id, per row (default mode), in one or more analyze.py jsonl files.
usage: clcount.py <cluster ids comma> <label=jsonl>...   (fenced rows refused, common.fenced())"""
import sys, os, json, csv, collections
H = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, H)
from common import fenced, rekey
F = fenced()
K = {r['key']: r['cluster_id'] for r in csv.DictReader(open(os.path.join(H, '..', '..', 'r11u189map', 'cluster_index.csv')))}
ids = sys.argv[1].split(',')
res = collections.defaultdict(dict)
for a in sys.argv[2:]:
    lab, p = a.split('=', 1)
    for l in open(p):
        r = json.loads(l)
        if r['mode'] != 'default': continue
        assert r['test'] not in F
        c = collections.Counter(K.get(rekey(f), 'NEW') for f in r['rows'])
        res[r['test']][lab] = (len(r['rows']), {i: c.get(i, 0) for i in ids})
labs = [a.split('=', 1)[0] for a in sys.argv[2:]]
print('row\t' + '\t'.join(f'{l}:facets' for l in labs) + '\t' + '\t'.join(f'{i}:{l}' for i in ids for l in labs))
for t in sorted(res):
    if not all(l in res[t] for l in labs): continue
    print(t + '\t' + '\t'.join(str(res[t][l][0]) for l in labs) + '\t' + '\t'.join(str(res[t][l][1][i]) for i in ids for l in labs))
