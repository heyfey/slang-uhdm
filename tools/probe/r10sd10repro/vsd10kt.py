#!/usr/bin/env python3
# vsd10 kind-table scorer.  MULTISET per key (fullname@line:col) — an array
# local mints TWO objects at ONE key, and a join over such a table produces a
# CARTESIAN PRODUCT that reports spurious BREAKs (it did, on cell v1).
import sys, re, collections
def kt(p):
    d = collections.Counter()
    for L in open(p, errors='replace'):
        m = re.search(r'\\_([a-z_]*_var): \(([^)]*)\), line:(\d+:\d+)', L)
        if m: d[(m.group(2), m.group(3), m.group(1))] += 1
    return d
D = sys.argv[1]
G, P, Q = (kt(f'{D}/{n}.dump') for n in ('g', 'pris', 'pat'))
keys = sorted({(k[0], k[1]) for k in list(G) + list(P) + list(Q)})
tot = dict(same=0, FIX=0, BREAK=0, RESIDUE=0, OTHER=0)
skip = re.compile(r'work@(mailbox|process|semaphore|randomize)')
for name, loc in keys:
    if skip.search(name): continue
    g = collections.Counter({k[2]: v for k, v in G.items() if k[0] == name and k[1] == loc})
    p = collections.Counter({k[2]: v for k, v in P.items() if k[0] == name and k[1] == loc})
    q = collections.Counter({k[2]: v for k, v in Q.items() if k[0] == name and k[1] == loc})
    f = lambda c: '+'.join(f'{k}x{v}' if v > 1 else k for k, v in sorted(c.items())) or 'MISSING'
    if g == p == q: tag = 'same'
    elif g != p and g == q: tag = 'FIX'
    elif g == p and g != q: tag = 'BREAK'
    elif p == q: tag = 'RESIDUE'
    else: tag = 'OTHER'
    tot[tag] += 1
    if tag != 'same':
        print(f'  {tag:7s} {name}@{loc:9s} G={f(g):22s} P={f(p):22s} Q={f(q)}')
print('  [S] ' + ' '.join(f'{k}={v}' for k, v in tot.items()))
