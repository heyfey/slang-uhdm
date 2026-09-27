#!/usr/bin/env python3
"""r11u183: per cluster, the distinct walk-parent shapes (chain types, names dropped) with row counts + one example.
usage: shapes.py <jsonl> <ids,comma> [depth]"""
import sys, json, csv, os, re, collections
H = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(H, '..', '..', 'r11u179map')
sys.path.insert(0, os.path.join(M, 'drivers')); from common import rekey, fenced
F = fenced()
key2id = {r['key']: r['cluster_id'] for r in csv.DictReader(open(os.path.join(M, 'cluster_index.csv')))}
want = set(sys.argv[2].split(',')); dep = int(sys.argv[3]) if len(sys.argv) > 3 else 4
S = collections.defaultdict(lambda: collections.defaultdict(collections.Counter)); E = {}
for l in open(sys.argv[1]):
    r = json.loads(l)
    if r.get('test') in F: continue
    for x in r.get('rows', []):
        cid = key2id.get(rekey(x), 'NEW')
        if cid not in want: continue
        sh = ' < '.join(re.sub(r'\(.*', '', c) for c in x['chain'].split(' < ')[:dep])
        S[cid][sh][f"{r['corpus'][:3]}/{r['mode'][0]}/{r['test']}"] += 1
        E.setdefault((cid, sh), f"{r['test']} #{x['ia']}/{x['ib']} '{x['name']}' g={x['golden']} o={x['ours']} | {x['chain']}")
for cid in S:
    print(cid)
    for sh, rows in sorted(S[cid].items(), key=lambda kv: -sum(kv[1].values())):
        print(f"  {sum(rows.values()):6d} objs {len(rows):3d} rows  {sh}   [{' '.join(sorted(set(t.split('/')[2] for t in rows)))}]")
        print('         e.g.', E[(cid, sh)][:260])
