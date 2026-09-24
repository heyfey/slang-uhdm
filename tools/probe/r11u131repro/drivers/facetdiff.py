#!/usr/bin/env python3
"""facetdiff.py <P.jsonl> <L.jsonl>: per row-mode, the analyzer's facet
clusters (every differing object, including those after the first walk
divergence) of the pristine and the law sweep; prints every row where some
cluster gained objects (a candidate worsening the strict column cannot show)
and a summary."""
import json, sys
from collections import Counter
def load(p):
    d = {}
    for l in open(p):
        r = json.loads(l)
        d[(r['corpus'], r['mode'], r['test'])] = Counter(f['cluster'] for f in r['rows'])
    return d
P, L = load(sys.argv[1]), load(sys.argv[2])
up = 0; down = 0
for k in sorted(set(P) | set(L)):
    a, b = P.get(k, Counter()), L.get(k, Counter())
    gains = {c: (a[c], b[c]) for c in set(a) | set(b) if b[c] > a[c]}
    if sum(b.values()) < sum(a.values()): down += 1
    if gains:
        up += 1
        print('GAIN', '/'.join(k), sum(a.values()), '->', sum(b.values()), gains)
print(f'SUMMARY rows={len(set(P)|set(L))} rows-with-a-gain={up} rows-with-fewer-facets={down}')
