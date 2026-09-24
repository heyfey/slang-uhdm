#!/usr/bin/env python3
"""yieldmap.py all.jsonl — per remaining strict-NE row-mode, the set of
facet clusters (analyze.py, the r11u122 cluster key); prints the clusters
ranked by rows, with ALONE yield (rows whose ONLY cluster it is) and the
clusters' pair yields; plus rows by cluster count."""
import collections, json, sys
R = [json.loads(l) for l in open(sys.argv[1])]
rows = {}
err = 0
for r in R:
    if 'error' in r:
        err += 1; continue
    rows[(r['corpus'], r['mode'], r['test'])] = {x['cluster'] for x in r['rows']}
cnt = collections.Counter(); alone = collections.Counter()
for k, s in rows.items():
    for c in s: cnt[c] += 1
    if len(s) == 1: alone[next(iter(s))] += 1
print('rows', len(rows), 'errors', err, 'empty', sum(1 for s in rows.values() if not s))
print('by #clusters', sorted(collections.Counter(min(len(s), 10) for s in rows.values()).items()))
flt = sys.argv[2] if len(sys.argv) > 2 else ''
for c, n in cnt.most_common(int(sys.argv[3]) if len(sys.argv) > 3 else 60):
    if flt and flt not in c: continue
    print(f'{n:5d} alone={alone[c]:4d}  {c}')
