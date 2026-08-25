#!/usr/bin/env python3
"""r10v84 (VERIFIER) — 3-way per-cell verdict over ct84cen rows.
MEASUREMENT ONLY.  Multiset join on the KEY half; payload compared field by
field.  Verdicts, per cell:
  SAME->SAME    pris == golden and patched == golden
  WRONG->RIGHT  pris != golden and patched == golden
  RIGHT->WRONG  pris == golden and patched != golden      <-- the regression
  WRONG->WRONG  neither matches, and patched == pris
  WRONG->OTHER  neither matches, and patched != pris
  ONLY-*        the key is absent on a side (multiset surplus)
usage: vscore84.py <dir> [--slot BASE] [--only-diff]
"""
import sys, collections
d = sys.argv[1]
args = sys.argv[2:]
slot = None
if '--slot' in args: slot = args[args.index('--slot')+1]
onlydiff = '--only-diff' in args

def load(p):
    m = collections.defaultdict(list)
    try:
        for ln in open(p):
            ln = ln.rstrip('\n')
            if '\t||\t' not in ln: continue
            k, v = ln.split('\t||\t', 1)
            m[k].append(v)
    except FileNotFoundError:
        pass
    for k in m: m[k].sort()
    return m

G, O, Q = load(d+'/g.rows'), load(d+'/o.rows'), load(d+'/q.rows')
keys = sorted(set(G) | set(O) | set(Q))
tally = collections.Counter()
rows = []
for k in keys:
    if slot and ('SLOT='+slot) not in k: continue
    g, o, q = G.get(k, []), O.get(k, []), Q.get(k, [])
    n = max(len(g), len(o), len(q))
    for i in range(n):
        gv = g[i] if i < len(g) else '<ABSENT>'
        ov = o[i] if i < len(o) else '<ABSENT>'
        qv = q[i] if i < len(q) else '<ABSENT>'
        if gv == '<ABSENT>':   ver = 'ONLY-OURS'
        elif ov == '<ABSENT>' or qv == '<ABSENT>': ver = 'ONLY-GOLDEN'
        elif ov == gv and qv == gv: ver = 'SAME->SAME'
        elif ov != gv and qv == gv: ver = 'WRONG->RIGHT'
        elif ov == gv and qv != gv: ver = 'RIGHT->WRONG'
        elif qv == ov:              ver = 'WRONG->WRONG'
        else:                       ver = 'WRONG->OTHER'
        tally[ver] += 1
        if not onlydiff or ver not in ('SAME->SAME',):
            rows.append((ver, k, gv, ov, qv))
for ver, k, gv, ov, qv in rows:
    print(f'[{ver}] {k}')
    if ver != 'SAME->SAME':
        print(f'    G: {gv}')
        print(f'    O: {ov}')
        print(f'    Q: {qv}')
print('-- ' + '  '.join(f'{k}={v}' for k, v in sorted(tally.items())))
