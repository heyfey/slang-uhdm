#!/usr/bin/env python3
"""r11u179 (map 8's evid.py; r11u132 origin): one evidence file
per wanted cluster, the smallest example row (probe cases first when the cluster
has no corpus row). Record lines: the 14 fields, then rawFull and the mode-4
flags (refRoot root inCopy). Also writes objects.csv: one example per cluster
for EVERY cluster. Args: <work> <corpus dumps> <probe dumps> <out dir> <cluster ids...|ALLOBJ>"""
import os, sys, json, csv
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
from analyze import load, parents
W, DUMPS, PDUMPS, OUT = sys.argv[1:5]; WANT = set(sys.argv[5:])
ids = json.load(open(f'{W}/ids.json')); cid = ids['cid']
ids['cov'] = {r['key']: r['coverage'] + ' | ground ' + r['ground'] + ' | site ' + r['site'] for r in csv.DictReader(open(f'{W}/out/cluster_index.csv'))}   # r11u189: report10.py's coverage
R = [json.loads(l) for l in open(f'{W}/corpus.jsonl')]; RP = [json.loads(l) for l in open(f'{W}/probe.jsonl')]
for r in R: r['_d'] = f"{DUMPS}/{r['corpus']}/{r['mode']}/{r['test']}"
for r in RP: r['_d'] = f"{PDUMPS}/probe/default/{r['test']}"
for r in R + RP:
    for x in r['rows']: x['cluster'] = rekey(x)
best = {}
for src in (R, RP):
    for r in src:
        for x in r['rows']:
            c = x['cluster']
            if c in best and best[c][3] is not src: continue
            cand = (r['nA'], len(r['rows']))
            if c not in best or cand < best[c][0]: best[c] = (cand, r, x, src)
os.makedirs(f'{OUT}/clusters', exist_ok=True)
with open(f'{OUT}/objects.csv', 'w', newline='') as f:
    w = csv.writer(f); w.writerow(['cluster_id', 'row', 'golden_index', 'ours_index', 'type', 'name', 'walk_parents', 'golden', 'ours', 'fnclass'])
    for c in sorted(best, key=lambda c: cid[c]):
        _, r, x, _s = best[c]
        w.writerow([cid[c], f"{r['corpus']}/{r['mode']}/{r['test']}", x['ia'], x['ib'], x['type'], x['name'], x['chain'], x['golden'][:200], x['ours'][:200], x.get('fnclass', '')])
fmt = lambda rr: '\t'.join(rr[:15]) + '\t' + ''.join('1' if b else '0' for b in rr[15:18])
cache = {}
for c in sorted((c for c in cid if cid[c] in WANT), key=lambda c: best[c][1]['_d']):
    _, r, x, _s = best[c]
    key = r['_d']
    if key not in cache:
        cache.clear(); A, B = load(key + '.a'), load(key + '.b'); cache[key] = (A, B, parents(A), parents(B))
    A, B, pA, pB = cache[key]
    fn = f"{OUT}/clusters/{cid[c]}_{r['corpus']}_{r['mode']}_{r['test'][:80]}.txt"
    with open(fn, 'w') as f:
        f.write(f"cluster {cid[c]} (id {'kept from an earlier map' if ids['old'].get(c) else 'new in r11u189map'}; {ids['cov'][c]}): {c}\n")
        f.write(f"row: {r['corpus']}/{r['mode']}/{r['test']}  strict={r['strict'] if r['corpus'] != 'probe' else r['verify']['tool_first']}  records golden={r['nA']} ours={r['nB']}\n")
        f.write(f"object: #{x['ia']} (golden) / #{x['ib']} (ours)  type={x['type']} name={x['name']} {x.get('fnclass', '')}\n  golden: {x['golden']}\n  ours:   {x['ours']}\n  walk parents: {x['chain']}\n")
        f.write("record fields: depth type name defname fullname(<in>tail inside a copy) file line col endline endcol decompile size value consttype rawFull flags(refRoot root inCopy)\n")
        for side, idx, Rr in (('GOLDEN (A)', x['ia'], A), ('OURS (B)', x['ib'], B)):
            if idx < 0: continue
            lo = max(0, idx - 6); hi = min(len(Rr), idx + 7)
            f.write(f"\n--- {side} records {lo}..{hi-1} ('>' = the object)\n")
            for i in range(lo, hi): f.write(('> ' if i == idx else '  ') + f"#{i}\t" + fmt(Rr[i]) + '\n')
        if x['ia'] < 0 or x['ib'] < 0:
            idx = x['ia'] if x['ia'] >= 0 else x['ib']
            Rr, other, P = (A, B, pA) if x['ia'] >= 0 else (B, A, pB)
            par = P[idx]; sig = Rr[par][:14] if par >= 0 else None
            cand = [i for i, rr in enumerate(other) if sig is not None and rr[:14] == sig]
            f.write(f"\n--- the holder #{par} on the other side: exact-record matches at {cand[:5]}\n")
            for j in cand[:1]:
                for i in range(max(0, j - 3), min(len(other), j + 10)): f.write(('> ' if i == j else '  ') + f"#{i}\t" + fmt(other[i]) + '\n')
        f.write(f"\nfacets of this row ({len(r['rows'])}, first 25):\n")
        for y in r['rows'][:25]:
            f.write(f"  {cid[y['cluster']]} #{y['ia']}/{y['ib']} {y['type']} {y['name']} G[{y['golden'][:80]}] O[{y['ours'][:80]}]\n")
print('objects', len(best))
