#!/usr/bin/env python3
"""r11u183: key the analyzer rows (r11u179map/drivers/analyze.py output) to map 9's cluster ids
(r11u179map/cluster_index.csv key column; map 8's rekey from r11u179map/drivers/common.py).
usage: clus.py <corpus.jsonl> <ids,comma> [--ex N]  -> per cluster: rows (test/mode: objects) + N examples."""
import sys, json, csv, os, collections
H = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(H, '..', '..', 'r11u179map')
sys.path.insert(0, os.path.join(M, 'drivers')); from common import rekey, fenced
F = fenced()
key2id = {r['key']: r['cluster_id'] for r in csv.DictReader(open(os.path.join(M, 'cluster_index.csv')))}
want = set(sys.argv[2].split(',')) if len(sys.argv) > 2 and sys.argv[2] != 'all' else None
ex = int(sys.argv[sys.argv.index('--ex') + 1]) if '--ex' in sys.argv else 3
per = collections.defaultdict(lambda: collections.Counter()); exs = collections.defaultdict(list)
for l in open(sys.argv[1]):
    r = json.loads(l)
    if r.get('test') in F: continue
    for x in r.get('rows', []):
        k = rekey(x); cid = key2id.get(k, 'NEW:' + k)
        if want and cid not in want: continue
        tag = f"{r['corpus'][:3]}/{r['mode'][0]}/{r['test']}"
        per[cid][tag] += 1
        if len(exs[cid]) < ex: exs[cid].append(f"{tag} #{x['ia']}/{x['ib']} {x['type']} '{x['name']}' g={x['golden']} o={x['ours']} | {x['chain']}")
for cid in sorted(per, key=lambda c: -len(per[c])):
    print(f"{cid} rows={len(per[cid])} objs={sum(per[cid].values())}: " + ' '.join(f'{t}:{n}' for t, n in sorted(per[cid].items())))
    for e in exs[cid]: print('   ', e[:330])
