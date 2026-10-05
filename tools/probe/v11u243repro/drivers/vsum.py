#!/usr/bin/env python3
"""vsum.py <grid> <cfgA> <cfgB>: per case-view, cfgA vs cfgB: verdict (cmp lines, strict) and md5; flags moves."""
import sys, collections
g = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    d = dict(x.split('=', 1) for x in f[2:] if '=' in x)
    d['raw'] = ' '.join(f[2:])
    g[f[0]][f[1]] = d
A, B = sys.argv[2], sys.argv[3]
cnt = collections.Counter()
for cv in sorted(g):
    a, b = g[cv].get(A), g[cv].get(B)
    if not a or not b: print(cv, 'MISSING'); continue
    va = (a.get('cmplines'), a.get('strict')); vb = (b.get('cmplines'), b.get('strict'))
    same = a.get('md5') == b.get('md5')
    tag = 'same-bytes' if same else ('bytes-moved' if va == vb else 'VERDICT')
    cnt[tag] += 1
    if not same:
        print(f"{cv:34s} {tag:11s} {A}: cmp={va[0]} {va[1]} rc={a.get('rc')} | {B}: cmp={vb[0]} {vb[1]} rc={b.get('rc')}")
print(dict(cnt))
