#!/usr/bin/env python3
"""r11u230 map: what moved in the map since map 14 (tools/probe/r11u222map, 551c9751 with its 75a564b0 addendum),
keyed by cluster id (ids persist by key). Args: <repo> <out dir of final15.py>. Reads map 14's clusters.csv,
probe_clusters.csv, cluster_index.csv and this map's. Prints gone / fell / grew / new, per cluster the row-modes and
cases it lost or gained."""
import csv, sys, collections
REPO, OUT = sys.argv[1:3]
M14 = f'{REPO}/tools/probe/r11u222map'
def load(p, keyf):
    d = collections.defaultdict(set)
    for r in csv.DictReader(open(p)): d[r['cluster_id']].add(keyf(r))
    return d
ck = lambda r: f"{r['test']}/{r['mode'][0]}"
pk = lambda r: r['case']
oc, nc = load(f'{M14}/clusters.csv', ck), load(f'{OUT}/clusters.csv', ck)
op, np_ = load(f'{M14}/probe_clusters.csv', pk), load(f'{OUT}/probe_clusters.csv', pk)
ids = set(oc) | set(nc) | set(op) | set(np_)
key = {r['cluster_id']: r['key'] for r in csv.DictReader(open(f'{M14}/cluster_index.csv'))}
import json, os
nk = {}
p = os.path.join(os.path.dirname(OUT.rstrip('/')), 'ids.json')
if os.path.exists(p): nk = json.load(open(p))['key']
def line(c):
    a, b = oc.get(c, set()), nc.get(c, set()); x, y = op.get(c, set()), np_.get(c, set())
    return f"{c} rows {len(a)}->{len(b)} cases {len(x)}->{len(y)} | -rows {' '.join(sorted(a - b))} +rows {' '.join(sorted(b - a))} | -cases {len(x - y)} +cases {len(y - x)} | {key.get(c) or nk.get(c, '')}"
gone = sorted(c for c in ids if (c in oc or c in op) and c not in nc and c not in np_)
new = sorted(c for c in ids if c not in oc and c not in op)
fell = sorted(c for c in ids if c not in gone and c not in new and (len(nc.get(c, ())) < len(oc.get(c, ())) or len(np_.get(c, ())) < len(op.get(c, ()))))
grew = sorted(c for c in ids if c not in gone and c not in new and (len(nc.get(c, ())) > len(oc.get(c, ())) or len(np_.get(c, ())) > len(op.get(c, ()))))
print('clusters map14', len(set(oc) | set(op)), 'now', len(set(nc) | set(np_)))
for t, L in (('GONE', gone), ('NEW', new), ('FELL', fell), ('GREW', grew)):
    print(f'== {t} {len(L)}')
    for c in L: print('  ' + line(c))
# row-mode and case level
orow = {k for s in oc.values() for k in s}; nrow = {k for s in nc.values() for k in s}
ocase = {k for s in op.values() for k in s}; ncase = {k for s in np_.values() for k in s}
print('row-modes map14', len(orow), 'now', len(nrow), 'left:', ' '.join(sorted(orow - nrow)), 'entered:', ' '.join(sorted(nrow - orow)))
print('cases map14', len(ocase), 'now', len(ncase), 'left:', ' '.join(sorted(ocase - ncase)), 'entered:', ' '.join(sorted(ncase - ocase)))
