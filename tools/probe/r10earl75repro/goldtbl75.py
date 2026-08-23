#!/usr/bin/env python3
# r10earl75 — per-ROW golden table for a grid arm: for every constant cell,
# what GOLDEN stamps and what we stamped before / after, labelled by source
# line.  MEASUREMENT ONLY.  usage: goldtbl75.py <gold.n> <pris.n> <patc.n>
import sys
from collections import defaultdict
NK = 9
def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        d[' '.join(f[:NK])].append(' '.join(f[NK:]))
    return d
g, o, q = (load(a) for a in sys.argv[1:4])
def ts(p):
    if p == '<none>': return 'NO-CELL'
    d = dict(t.split('=', 1) for t in p.split() if '=' in t)
    if d.get('ts') == '-': return 'bare'
    return d.get('ts', '?') + ('/sgn' + d.get('tssgn', '?'))
rows = defaultdict(lambda: [set(), set(), set(), 0])
for k in set(g) | set(o) | set(q):
    f = k.split(' ')
    line = f[8].split('=')[1].split(':')[0]
    lbl = (int(line), f[2], f[3], f[4])
    G, O, Q = sorted(g.get(k, [])), sorted(o.get(k, [])), sorted(q.get(k, []))
    n = max(len(G), len(O), len(Q))
    G += ['<none>']*(n-len(G)); O += ['<none>']*(n-len(O)); Q += ['<none>']*(n-len(Q))
    for i in range(n):
        r = rows[lbl]
        r[0].add(ts(G[i])); r[1].add(ts(O[i])); r[2].add(ts(Q[i])); r[3] += 1
print(f'{"line":>5} {"owner":13} {"site":16} {"path":26} {"n":>3}  '
      f'{"GOLDEN":22} {"pristine":22} {"patched":22} verdict')
for (line, owner, site, path), (G, O, Q, n) in sorted(rows.items()):
    gs, os_, qs = '|'.join(sorted(G)), '|'.join(sorted(O)), '|'.join(sorted(Q))
    if gs == 'NO-CELL':      v = 'no golden cell' + ('  MOVED' if os_ != qs else '')
    elif qs == gs and os_ != qs: v = 'TO-GOLDEN'
    elif qs == gs:            v = 'right, unmoved'
    elif os_ == gs:           v = 'AWAY-GOLDEN'
    elif os_ == qs:           v = 'still wrong'
    else:                     v = 'MOVED-WRONG'
    print(f'{line:>5} {owner:13} {site:16} {path:26} {n:>3}  {gs:22} {os_:22} {qs:22} {v}')
