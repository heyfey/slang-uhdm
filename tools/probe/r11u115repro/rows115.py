#!/usr/bin/env python3
"""rows115.py <mine.csv> <base.csv> [...pairs]: status+dump row join (name,mode) -> prints every
differing row both sides and a status histogram of <mine>."""
import csv, sys, collections
args = sys.argv[1:]
for i in range(0, len(args), 2):
    mine, base = args[i], args[i+1]
    def load(p):
        d = {}
        for r in csv.DictReader(open(p)): d[(r['name'], r['mode'])] = (r['status'], r.get('dump', ''))
        return d
    a = load(mine); b = load(base)
    keys = sorted(set(a) | set(b))
    diff = [(k, b.get(k), a.get(k)) for k in keys if a.get(k) != b.get(k)]
    print(f'{mine} vs {base}: rows {len(a)}/{len(b)} differing {len(diff)}')
    for k, x, y in diff: print(f'   {k[0]},{k[1]}: base={x} mine={y}')
    print('   ', dict(collections.Counter((k[1], v[0]) for k, v in a.items())))
