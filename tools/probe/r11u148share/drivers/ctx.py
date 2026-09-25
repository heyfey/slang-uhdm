#!/usr/bin/env python3
"""ctx.py DUMP INDEX [AFTER]: the walk-path chain (ancestors by depth) of record INDEX (0-based, as strictcmp's #N)
and the AFTER records following it."""
import sys
recs=[l.rstrip('\n').split('\t') for l in open(sys.argv[1])]
i=int(sys.argv[2]); after=int(sys.argv[3]) if len(sys.argv)>3 else 6
def show(j,r): return f"#{j} d{r[0]} {r[1]} name={r[2]} full={r[4]} {r[5]}:{r[6]}.{r[7]}-{r[8]}.{r[9]} dec={r[10] if len(r)>10 else ''} val={r[12] if len(r)>12 else ''}"
chain=[]; d=int(recs[i][0])
for j in range(i-1,-1,-1):
    dj=int(recs[j][0])
    if dj<d: chain.append((j,recs[j])); d=dj
    if d==0: break
for j,r in reversed(chain): print('  up', show(j,r))
for j in range(i,min(len(recs),i+after)): print('  ->', show(j,recs[j]))
