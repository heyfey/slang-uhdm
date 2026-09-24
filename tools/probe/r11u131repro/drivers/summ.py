#!/usr/bin/env python3
"""summ.py <P.jsonl> [N]: clusters ranked by row-modes, with the rows they alone block."""
import json, sys
from collections import defaultdict, Counter
rows = [json.loads(l) for l in open(sys.argv[1])]
N = int(sys.argv[2]) if len(sys.argv) > 2 else 60
cl_rows = defaultdict(set); cl_obj = Counter(); ex = {}
row_cl = {}
for r in rows:
    k = (r['corpus'], r['mode'], r['test'])
    s = set()
    for f in r['rows']:
        c = f['cluster']; s.add(c); cl_rows[c].add(k); cl_obj[c] += f.get('nobj', 1)
        ex.setdefault(c, (k, f['name'], f['golden'], f['ours'], f['chain']))
    row_cl[k] = s
alone = Counter()
for k, s in row_cl.items():
    if len(s) == 1: alone[next(iter(s))] += 1
for c in sorted(cl_rows, key=lambda c: -len(cl_rows[c]))[:N]:
    k, nm, g, o, ch = ex[c]
    print(f"{len(cl_rows[c]):4d} alone={alone[c]:3d} obj={cl_obj[c]:6d} {c}\n      e.g. {'/'.join(k)} {nm!r} G={g!r} O={o!r} [{ch}]")
