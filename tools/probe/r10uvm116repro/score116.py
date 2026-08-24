#!/usr/bin/env python3
# r10uvm116repro/score116.py — the MOVER SCORE for one cell.  MEASUREMENT ONLY.
#
#   score116.py <cen.g.pris> <cen.o.pris> <cen.g.pat> <cen.o.pat>
#
# Every cell is a (FORM, KEY) group holding a MULTISET of payloads (the DEF and
# the ELAB view emit the same site twice, so a set would halve the population).
# A cell is EQUAL when golden's multiset and ours are identical.  The golden
# side is read from BOTH runs and asserted identical — a scorer that does not
# re-read golden cannot tell a golden change from a mover.
#
#   TO-GOLDEN    was unequal, is now EQUAL
#   AWAY-GOLDEN  was EQUAL, is now unequal            (must be 0)
#   STILL-WRONG  unequal both times AND our side CHANGED   (must be 0)
#   UNTOUCHED    unequal both times, our side identical
#   EQUAL-BOTH   equal both times
import sys, collections

def load(p):
    c = collections.defaultdict(collections.Counter)
    for line in open(p):
        f = line.rstrip('\n').split('\t')
        if len(f) < 4: continue
        c[(f[0], f[2])][f[3]] += 1
    return c

gp, op, gq, oq = (load(x) for x in sys.argv[1:5])
if dict(gp) != dict(gq):
    print('FATAL: the GOLDEN side differs between the two runs'); sys.exit(9)
keys = set(gp) | set(op) | set(gq) | set(oq)
tally = collections.Counter()
rows = []
for k in sorted(keys):
    g = gp.get(k, collections.Counter()); a = op.get(k, collections.Counter())
    b = oq.get(k, collections.Counter())
    was, now, moved = (g == a), (g == b), (a != b)
    if was and now:      cls = 'EQUAL-BOTH'
    elif not was and now: cls = 'TO-GOLDEN'
    elif was and not now: cls = 'AWAY-GOLDEN'
    elif moved:           cls = 'STILL-WRONG'
    else:                 cls = 'UNTOUCHED'
    tally[cls] += 1
    if cls in ('TO-GOLDEN', 'AWAY-GOLDEN', 'STILL-WRONG'):
        rows.append('%s\t%s' % (cls, '|'.join(k)))
for r in rows: print(r)
print('-- ' + ' '.join('%s=%d' % (c, tally[c]) for c in
      ('TO-GOLDEN', 'AWAY-GOLDEN', 'STILL-WRONG', 'UNTOUCHED', 'EQUAL-BOTH')))
