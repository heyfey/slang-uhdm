#!/usr/bin/env python3
# r11v45/dircen — judge-visible direction census, written by the verifier.
# Key: the TP lines of vid with POINTER IDS and SPANS removed (no generated
# Compare reads VpiParent, VpiFile or a source location; VpiName IS read).
#   dircen.py <golden.vid> <pristine.vid> <patched.vid>
import sys, re, collections
def load(p):
    c = collections.Counter()
    for ln in open(p):
        if not ln.startswith('TP '): continue
        f = ln.split()
        listing, owner = f[1], f[2]
        kind = [x for x in f if x.startswith('kind=')][0]
        rng  = [x for x in f if x.startswith('ranges=')][0]
        nm   = [x for x in f if x.startswith('tsname=')][0]
        c[f'{listing} {owner} -> {kind} {rng} {nm}'] += 1
    return c
g, a, b = (load(x) for x in sys.argv[1:4])
def diff(x):                       # facts where ours != golden, as a multiset
    d = collections.Counter()
    for k in set(x) | set(g):
        n = x[k] - g[k]
        if n: d[k] = n
    return d
da, db = diff(a), diff(b)
print(f'differing facts: pristine={sum(abs(v) for v in da.values())} patched={sum(abs(v) for v in db.values())}')
to   = [k for k in da if da[k] and db[k] != da[k]]
away = [k for k in db if db[k] and da[k] != db[k]]
for k in sorted(set(da) | set(db)):
    if da[k] == db[k]: continue
    print(f'  pris={da[k]:+d} pat={db[k]:+d}  {k}')
