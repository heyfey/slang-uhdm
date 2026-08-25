#!/usr/bin/env python3
"""r10uvm133 — three-way MULTISET score of one arm view.  MEASUREMENT ONLY.

For each SOURCE LINE the assignment-RHS descriptors of golden / pristine /
patched are collected as MULTISETS (a line appears once per listing copy — the
elab view carries the class body twice — so a last-writer dict would drop
rows).  Per line the score is:

  TOGOLD      pristine differed from golden, patched matches it
  MOVEDWRONG  pristine matched golden, patched no longer does
  MOVEDOTHER  neither matched, patched changed anyway
  STILLWRONG  neither matched, patched unchanged

and, split out of MOVEDWRONG, AWAY = a KEPT `sys_func_call` where golden folds.
Usage: score133.py <g.dump> <pris.dump> <pat.dump> [label]
"""
import sys, collections
import cen133

def ms(path):
    d = collections.defaultdict(collections.Counter)
    for line, kind, nm, val in cen133.cells(path):
        d[line][(kind, nm, val)] += 1
    return d

g, p, q = ms(sys.argv[1]), ms(sys.argv[2]), ms(sys.argv[3])
label = sys.argv[4] if len(sys.argv) > 4 else ''
tot = collections.Counter()
rows = []
for line in sorted(set(g) | set(p) | set(q)):
    G, P, Q = g.get(line, collections.Counter()), p.get(line, collections.Counter()), q.get(line, collections.Counter())
    if G == P == Q:
        tot['SAME'] += 1
        continue
    if P != G and Q == G:
        v = 'TOGOLD'
    elif P == G and Q != G:
        v = 'AWAY' if any(k[0] == 'sys_func_call' for k in (Q - G)) and any(k[0] == 'constant' for k in (G - Q)) else 'MOVEDWRONG'
    elif P != G and Q != G and P != Q:
        v = 'MOVEDOTHER'
    elif P != G and Q != G:
        v = 'STILLWRONG'
    else:
        v = 'SAME'
    tot[v] += 1
    if v != 'SAME':
        rows.append((line, v, dict(G), dict(P), dict(Q)))
for r in rows:
    if r[1] != 'STILLWRONG':
        print(f'{label}\tL{r[0]}\t{r[1]}\tG={r[2]}\tP={r[3]}\tQ={r[4]}')
print(f'{label}\tTOTALS\t' + ' '.join(f'{k}={v}' for k, v in sorted(tot.items())))
