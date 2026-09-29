#!/usr/bin/env python3
"""r11u230map: per fail-list row-mode, its clusters in WALK ORDER (the earliest record of each cluster), with the ground
(report15.py's rule: decoded override, else the writer's file, else the mint's), the writer frame's own ground and the
record: the joint rows' A and B halves as a pair would meet them.  Args: <work W> <out dir (cluster_index.csv)> [tests...]"""
import json, csv, sys, os, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey, fenced
W, OUT = sys.argv[1:3]; T = set(sys.argv[3:])
FEN = fenced()
cid = json.load(open(f'{W}/ids.json'))['cid']
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
for l in open(f'{W}/corpus.jsonl'):
    r = json.loads(l)
    if r['test'] in FEN or (T and r['test'] not in T): continue
    first = {}
    for x in r['rows']:
        c = cid.get(rekey(x)); q = x['ia'] if x['ia'] >= 0 else x['ib']
        if c not in first or q < first[c][0]: first[c] = (q, x)
    print(f"== {r['corpus']}/{r['mode']}/{r['test']} {r['strict']}: {len(first)} clusters, ground A {sum(1 for c in first if CI[c]['ground'] == 'A')}, B {sum(1 for c in first if CI[c]['ground'] == 'B')}")
    for c, (q, x) in sorted(first.items(), key=lambda kv: kv[1][0]):
        ci = CI[c]; wg = ci.get('writer_chain_grounds', '-')
        print(f"   #{q:<7} {c} {ci['ground']} (writer chain {wg}) {x['type']} '{x['name'][:40]}' {x['facet']}:{x['fields']} g={x['golden'][:50]} o={x['ours'][:50]} | {ci.get('writer', '-')[:110]}")
