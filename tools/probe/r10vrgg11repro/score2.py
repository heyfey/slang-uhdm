#!/usr/bin/env python3
"""r10vrgg11 scorer v2 — order-blind multiset over normalised dumps.
   Per cell reports the SYMMETRIC DIFFERENCE to golden for base and pat.
   HARD-REGRESSION  : base symdiff == 0 (byte-perfect) and pat symdiff > 0.
   NET-WORSE        : pat symdiff > base symdiff.
   NET-BETTER       : pat symdiff < base symdiff.
   FIELD-LOST       : a golden line base matched and pat no longer matches
                      (reported even when the cell is net-better).
"""
import os, sys
from collections import Counter
O = sys.argv[1]; SHOW = '--all' in sys.argv
def load(p):
    if not os.path.exists(p): return None
    ls = [l for l in open(p, errors='replace').read().split('\n')
          if 'Restored design' not in l]
    return Counter(ls)
cells = sorted(set(f[:-len('.gold.dump')] for f in os.listdir(O) if f.endswith('.gold.dump')))
hard, worse, better, same, missing, lostcells = [], [], [], [], [], []
for n in cells:
    g, b, p = (load(os.path.join(O, n + s)) for s in ('.gold.dump','.base.dump','.pat.dump'))
    if not all(x is not None for x in (g,b,p)): missing.append(n); continue
    db = sum((g-b).values()) + sum((b-g).values())
    dp = sum((g-p).values()) + sum((p-g).values())
    lost = (g-p) - (g-b)
    if lost: lostcells.append((n, sum(lost.values()), db, dp, list(lost.elements())[:3]))
    if db == 0 and dp > 0: hard.append((n, db, dp))
    elif dp > db: worse.append((n, db, dp))
    elif dp < db: better.append((n, db, dp))
    else: same.append((n, db, dp))
print('-- cells=%d  HARD-REGRESSION=%d NET-WORSE=%d NET-BETTER=%d UNCHANGED=%d MISSING=%d  (FIELD-LOST cells=%d)'
      % (len(cells), len(hard), len(worse), len(better), len(same), len(missing), len(lostcells)))
for n,db,dp in hard:  print('HARD-REGRESSION %-45s basediff=%d patdiff=%d' % (n,db,dp))
for n,db,dp in worse: print('NET-WORSE       %-45s basediff=%d patdiff=%d' % (n,db,dp))
if SHOW:
    for e in lostcells: print('FIELD-LOST      %-45s n=%d basediff=%d patdiff=%d %s' % (e[0],e[1],e[2],e[3],e[4]))
    for n,db,dp in better: print('NET-BETTER      %-45s basediff=%d patdiff=%d' % (n,db,dp))
    for n,db,dp in same:   print('UNCHANGED       %-45s diff=%d' % (n,db))
