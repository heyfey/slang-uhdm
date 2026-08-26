#!/usr/bin/env python3
"""r10earl97 -- THE REGRESSION INSTRUMENT (reg96.py shape).  Per-KEY MULTISET
intersection of GOLDEN vs PRISTINE vs CANDIDATE ct97cen censuses.  Reports, for
every key, how the candidate moved relative to the pristine WITH RESPECT TO
GOLDEN:
   TO-GOLDEN     a payload the pristine got wrong and the candidate gets right
   AWAY-GOLDEN   a payload the pristine got right and the candidate gets wrong
   STILL-WRONG   wrong on both sides (unchanged or changed but still unequal)
   ADDED/REMOVED  the candidate created / dropped a row (must be 0)
usage: reg97.py golden.cen pristine.cen candidate.cen [--rows N]
"""
import sys, collections

def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln: continue
        k, _, v = ln.partition('\t')
        d[k][v] += 1
    return d

g, p, c = (load(a) for a in sys.argv[1:4])
nrows = int(sys.argv[sys.argv.index('--rows')+1]) if '--rows' in sys.argv else 0
to = away = still = added = removed = 0
rows = []
for k in set(g) | set(p) | set(c):
    gc, pc, cc = g.get(k, collections.Counter()), p.get(k, collections.Counter()), c.get(k, collections.Counter())
    if sum(cc.values()) != sum(pc.values()):
        d = sum(cc.values()) - sum(pc.values())
        if d > 0: added += d
        else: removed += -d
        rows.append(("COUNT", k, dict(gc), dict(pc), dict(cc)))
        continue
    pw = sum((pc - (gc & pc)).values())
    cw = sum((cc - (gc & cc)).values())
    if cw < pw:
        to += pw - cw; rows.append(("TO-GOLDEN", k, dict(gc), dict(pc), dict(cc)))
    elif cw > pw:
        away += cw - pw; rows.append(("AWAY-GOLDEN", k, dict(gc), dict(pc), dict(cc)))
    elif cw:
        still += cw
print(f"TO-GOLDEN {to} AWAY-GOLDEN {away} STILL-WRONG {still} ADDED {added} REMOVED {removed}")
for r in rows[:nrows]:
    print("  %-12s %s\n      golden=%s pristine=%s candidate=%s" % r)
