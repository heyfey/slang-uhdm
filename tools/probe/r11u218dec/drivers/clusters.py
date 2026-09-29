#!/usr/bin/env python3
"""clusters.py <analyzer jsonl> [cluster_index.csv]: per row, the differing objects tallied by map 13's cluster id
(map 11's key via tools/probe/r11u211map/drivers/common.py rekey; a key absent from map 13 prints NEW:<key>), in
first-appearance order, with the cluster's ground from map 13's index. Reads no source or database."""
import sys, os, json, csv, collections
here = os.path.dirname(os.path.abspath(__file__))
m13 = os.path.join(here, '..', '..', 'r11u211map')
sys.path.insert(0, os.path.join(m13, 'drivers'))
import common
idx = {}
for r in csv.DictReader(open(sys.argv[2] if len(sys.argv) > 2 else os.path.join(m13, 'cluster_index.csv'))):
    idx[r['key']] = (r['cluster_id'], r['ground'], r['site'][:90])
for l in open(sys.argv[1]):
    r = json.loads(l)
    if 'rows' not in r: print(r.get('test'), 'ERROR', r.get('error')); continue
    c = collections.OrderedDict()
    for x in r['rows']:
        k = common.rekey(x)
        c.setdefault(k, [0, x])[0] += x.get('nobj', 1)
    print(f"== {r['corpus']}/{r['mode']}/{r['test']} {r['verify'].get('tool_first')} ndiff={r['verify'].get('ndiff')} clusters={len(c)}")
    for k, (n, x) in c.items():
        cid, g, site = idx.get(k, ('NEW', '?', ''))
        print(f"  {cid:6} {g} {n:5}  {k[:110]}  | {x.get('golden','')[:60]} / {x.get('ours','')[:60]}")
