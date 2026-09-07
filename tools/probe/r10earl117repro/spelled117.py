#!/usr/bin/env python3
"""r10earl117 — THE MUST-STAY COLUMN, scored explicitly.

MEASUREMENT ONLY.  LHS is ALWAYS golden; RHS is ALWAYS ours.

"A genvar golden SPELLS must stay spelled."  This scorer restricts the census
to the cells where GOLDEN's payload contains a `ref_obj` — i.e. every select
bound Surelog itself left as an identifier — and reports, for that column
alone:
    SPELLED_AGREE   golden spells, we spell, before AND after   (must not drop)
    SPELLED_BROKEN  golden spells, we spelled, we now do not    (must be 0)
    SPELLED_STILL   golden spells, we never did                 (a residue)
and the same three for the complementary FOLDED column (golden constant).

usage: spelled117.py <gold.txt> <pris.txt> <patch.txt>
"""
import sys, collections

def load(p):
    per = collections.defaultdict(lambda: collections.defaultdict(collections.Counter))
    try:
        fh = open(p)
    except OSError:
        return per
    for l in fh:
        if not l.startswith('S|'):
            continue
        f = l.rstrip('\n').split('|')
        if len(f) < 13:
            continue
        per[f[1]][tuple(f[2:11])][tuple(f[11:13])] += 1
    return per

G, P, A = (load(a) for a in sys.argv[1:4])
tot = collections.Counter()
broke = []
for db in sorted(set(G) | set(P) | set(A)):
    g, p, a = G.get(db, {}), P.get(db, {}), A.get(db, {})
    for key in set(g):
        gc = g[key]
        col = 'SPELLED' if any(ik == 'ref_obj' for ik, it in gc) else \
              ('FOLDED' if any(ik == 'constant' for ik, it in gc) else 'OTHER')
        pc, ac = p.get(key), a.get(key)
        if pc == gc and ac == gc:
            tot[col + '_AGREE'] += 1
        elif pc == gc and ac != gc:
            tot[col + '_BROKEN'] += 1
            broke.append((col, db, key, pc, ac))
        elif pc != gc and ac == gc:
            tot[col + '_FIXED'] += 1
        elif pc == ac:
            tot[col + '_STILL'] += 1
        else:
            tot[col + '_MOVEDWRONG'] += 1
            broke.append((col + '_MOVEDWRONG', db, key, pc, ac))
print("  ".join("%s %d" % (k, tot[k]) for k in sorted(tot)))
for col, db, key, pc, ac in broke:
    print("  !! %-18s %-40s %s" % (col, db, '|'.join(key)))
    print("       pris=%s patch=%s" % (dict(pc or {}), dict(ac or {})))
