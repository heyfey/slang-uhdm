#!/usr/bin/env python3
"""UVM census: rank the map-8 cluster keys of the five UVM rows by objects, and list each
row's first ten differing records (walk order) with their cluster.
uvmcensus.py <analyze.jsonl> <map8 cluster_index.csv> <out prefix>"""
import json, csv, sys, collections
ana, idx, outp = sys.argv[1:4]
K = {}
for r in csv.DictReader(open(idx)):
    K[r['key']] = r
rows = {}
for l in open(ana):
    r = json.loads(l)
    if r['mode'] != 'default': continue
    rows[r['test']] = r
tot = collections.Counter(); per = collections.defaultdict(collections.Counter); ex = {}
for t, r in rows.items():
    for f in r['rows']:
        n = f.get('nobj', 1) if f['facet'] == 'struct' else 1
        tot[f['cluster']] += n; per[f['cluster']][t] += n
        ex.setdefault(f['cluster'], f"{t} #{f['ia']}/{f['ib']} {f['type']} '{f['name']}' g={f['golden'][:60]} o={f['ours'][:60]} < {f['chain'][:90]}")
with open(outp + '_rank.csv', 'w', newline='') as fo:
    w = csv.writer(fo)
    w.writerow(['rank', 'key', 'map8_id', 'objects', 'rows'] + sorted(rows) + ['ground', 'map8_coverage', 'site', 'example'])
    for i, (k, n) in enumerate(tot.most_common()):
        m = K.get(k, {})
        w.writerow([i + 1, k, m.get('cluster_id', 'NEW'), n, len(per[k])] + [per[k][t] for t in sorted(rows)] +
                   [m.get('ground', ''), m.get('coverage', ''), m.get('site', '')[:160], ex[k]])
with open(outp + '_first10.txt', 'w') as fo:
    for t in sorted(rows):
        fs = sorted([f for f in rows[t]['rows'] if f['ia'] >= 0], key=lambda f: f['ia'])[:10]
        fo.write(f'== {t} (default): {len(rows[t]["rows"])} facet rows\n')
        for f in fs:
            m = K.get(f['cluster'], {})
            fo.write(f"  #{f['ia']}/{f['ib']} {f['cluster']} [{m.get('cluster_id','NEW')} ground {m.get('ground','')}] {f['type']} '{f['name']}' golden={f['golden'][:50]} ours={f['ours'][:50]} < {f['chain'][:80]}\n")
print('rows', sorted(rows), 'keys', len(tot))
