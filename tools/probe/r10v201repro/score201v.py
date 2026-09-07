#!/usr/bin/env python3
# r10v201repro/score201v.py — the VERIFIER's Rhs-half TO-GOLDEN / AWAY-GOLDEN
# scorer.  MEASUREMENT ONLY; uhdm-cmp is the judge.
#
# Reads the per-arm `--list` files grid201v.sh writes (gold.list / pris.list /
# pat.list) and, for every param_assign CELL KEY, compares the multiset of
# Rhs-constant typespec KINDS on the two binaries against golden's.  A cell
# whose Rhs multiset moves CLOSER to golden's scores TO-GOLDEN; one that moves
# away scores AWAY-GOLDEN; one that moves inside a key golden does not carry at
# all (our const type or size already differs, so the cell cannot join) scores
# NEUTRAL and is PRINTED, never hidden — a neutral move is a cell the judge
# already lost at `expr::Compare`'s VpiSize (expr.cpp:95, ahead of Typespec at
# :100), not a cell this law got right.
#   usage: score201v.py <scratch dir written by grid201v.sh>
import re, os, sys, glob, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    if not os.path.exists(p): return None
    for line in open(p):
        m = re.match(r'^LIST \S+ key=(\S+) pay=(\S+) n=(\d+)', line)
        if m: d[m.group(1)][m.group(2)] += int(m.group(3))
    return d
root = sys.argv[1]
tot = collections.Counter(); det = []
for d in sorted(glob.glob(os.path.join(root, '*'))):
    arm = os.path.basename(d)
    g, r, p = load(d+'/gold.list'), load(d+'/pris.list'), load(d+'/pat.list')
    if not (g and r and p):
        print("SKIP", arm); continue
    for k in set(g) | set(r) | set(p):
        rh = lambda c: collections.Counter({pp.split('/')[0]: n for pp, n in c.items()})
        gg, rr, pp = rh(g[k]), rh(r[k]), rh(p[k])
        if rr == pp: continue
        inter = lambda x, y: sum((x & y).values())
        b, a = inter(gg, rr), inter(gg, pp)
        cls = 'TO-GOLDEN' if a > b else ('AWAY-GOLDEN' if a < b else 'NEUTRAL')
        tot[cls] += (a-b) if a > b else ((b-a) if a < b else 1)
        det.append((cls, arm, k, dict(gg), dict(rr), dict(pp)))
for x in sorted(det):
    print(f"{x[0]:12s} {x[1]:26s} {x[2]}\n             golden={x[3]} pris={x[4]} pat={x[5]}")
print("-- SCORED cells-moved=%d  %s" % (len(det), dict(tot)))
