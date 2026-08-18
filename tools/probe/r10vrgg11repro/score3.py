#!/usr/bin/env python3
import os, sys
from collections import Counter
O = sys.argv[1]; T = sys.argv[2]   # tag to compare against base
SHOW = '--all' in sys.argv
def load(p):
    if not os.path.exists(p): return None
    return Counter(l for l in open(p, errors='replace').read().split('\n') if 'Restored design' not in l)
cells = sorted(set(f[:-len('.gold.dump')] for f in os.listdir(O) if f.endswith('.gold.dump')))
hard, worse, better, same, lost = [], [], [], [], []
for n in cells:
    g,b,p = (load(os.path.join(O, n+s)) for s in ('.gold.dump','.base.dump','.'+T+'.dump'))
    if not all(x is not None for x in (g,b,p)): print('MISSING',n); continue
    db = sum((g-b).values()) + sum((b-g).values())
    dp = sum((g-p).values()) + sum((p-g).values())
    L = (g-p) - (g-b)
    if L: lost.append((n, sum(L.values()), db, dp))
    if db == 0 and dp > 0: hard.append((n,db,dp))
    elif dp > db: worse.append((n,db,dp))
    elif dp < db: better.append((n,db,dp))
    else: same.append((n,db,dp))
print('-- %s cells=%d HARD-REGRESSION=%d NET-WORSE=%d NET-BETTER=%d UNCHANGED=%d FIELD-LOST-cells=%d'
      % (T, len(cells), len(hard), len(worse), len(better), len(same), len(lost)))
for n,db,dp in hard: print('  HARD-REGRESSION %-45s basediff=%d %sdiff=%d' % (n,db,T,dp))
for n,db,dp in worse: print('  NET-WORSE       %-45s basediff=%d %sdiff=%d' % (n,db,T,dp))
for e in lost: print('  FIELD-LOST      %-45s n=%d basediff=%d %sdiff=%d' % (e[0],e[1],e[2],T,e[3]))
if SHOW:
    for n,db,dp in better: print('  NET-BETTER      %-45s basediff=%d %sdiff=%d' % (n,db,T,dp))
