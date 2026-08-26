#!/usr/bin/env python3
"""r10earl99 -- THE REGRESSION INSTRUMENT (reg97.py shape, ct99cen input).
Per-KEY MULTISET intersection of GOLDEN vs PRISTINE vs CANDIDATE censuses.
The scored payload is column 2 ONLY -- exactly the fields the official Compare
reads for a constant (VpiConstType / VpiSize / VpiDecompile / Typespec).
Column 3 (VAL=) is diagnostic and is NEVER scored unless --withval is passed.

   TO-GOLDEN     a payload the pristine got wrong and the candidate gets right
   AWAY-GOLDEN   a payload the pristine got right and the candidate gets wrong
   STILL-WRONG   wrong on both sides (unchanged, or changed but still unequal)
   ADDED/REMOVED the candidate created / dropped a row (must be 0)
usage: reg99.py golden.cen pristine.cen candidate.cen [--rows N] [--withval]
"""
import sys, collections

WITHVAL = '--withval' in sys.argv

def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln: continue
        parts = ln.split('\t')
        k = parts[0]
        v = parts[1] if len(parts) > 1 else ''
        if WITHVAL and len(parts) > 2:
            v = v + '\t' + parts[2]
        d[k][v] += 1
    return d

g, p, c = (load(a) for a in sys.argv[1:4])
nrows = int(sys.argv[sys.argv.index('--rows')+1]) if '--rows' in sys.argv else 0
to = away = still = added = removed = 0
bothsame = goldonly = oursonly = 0
rows = []
for k in set(g) | set(p) | set(c):
    gc, pc, cc = g.get(k, collections.Counter()), p.get(k, collections.Counter()), c.get(k, collections.Counter())
    if sum(cc.values()) != sum(pc.values()):
        d = sum(cc.values()) - sum(pc.values())
        if d > 0: added += d
        else: removed += -d
        rows.append(("COUNT", k, dict(gc), dict(pc), dict(cc)))
        continue
    if not gc and cc: oursonly += sum(cc.values()); continue
    if gc and not cc: goldonly += sum(gc.values()); continue
    pw = sum((pc - (gc & pc)).values())
    cw = sum((cc - (gc & cc)).values())
    bothsame += sum((gc & cc).values())
    if cw < pw:
        to += pw - cw; rows.append(("TO-GOLDEN", k, dict(gc), dict(pc), dict(cc)))
    elif cw > pw:
        away += cw - pw; rows.append(("AWAY-GOLDEN", k, dict(gc), dict(pc), dict(cc)))
    elif cw:
        still += cw
        rows.append(("STILL-WRONG", k, dict(gc), dict(pc), dict(cc)))
print(f"TO-GOLDEN {to} AWAY-GOLDEN {away} STILL-WRONG {still} ADDED {added} REMOVED {removed} "
      f"BOTH-SAME {bothsame} GOLDEN-ONLY-KEYS {goldonly} OURS-ONLY-KEYS {oursonly}")
shown = 0
for r in rows:
    if r[0] == 'STILL-WRONG': continue
    if shown >= nrows: break
    print("  %-12s %s\n      golden=%s pristine=%s candidate=%s" % r); shown += 1
