#!/usr/bin/env python3
"""One example object per (row-mode or probe case, cluster), with the count of
objects the cluster holds in that row. Args: <work dir> <out.csv>"""
import os, sys, json, csv
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
W, OUTF = sys.argv[1:3]
cid = json.load(open(f'{W}/ids.json'))['cid']
with open(OUTF, 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['row', 'cluster_id', 'objects', 'golden_index', 'ours_index', 'facet_fields', 'type', 'name', 'walk_parents', 'golden', 'ours', 'fnclass'])
    for src in ('corpus', 'probe'):
        for l in open(f'{W}/{src}.jsonl'):
            r = json.loads(l); ex = {}; n = {}
            for x in r['rows']:
                c = rekey(x); n[c] = n.get(c, 0) + x.get('nobj', 1)
                if c not in ex: ex[c] = x
            row = f"{r['corpus']}/{r['mode']}/{r['test']}" if src == 'corpus' else r['strict']
            for c in sorted(ex, key=lambda c: cid[c]):
                x = ex[c]
                w.writerow([row, cid[c], n[c], x['ia'], x['ib'], x['fields'], x['type'], x['name'], x['chain'][:120], x['golden'][:120], x['ours'][:120], x.get('fnclass', '')])
