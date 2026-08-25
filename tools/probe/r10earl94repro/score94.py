#!/usr/bin/env python3
"""r10earl94 — MULTISET join of two census files (keys collide; a last-writer
dict drops rows).  Prints BOTH-SAME / MOVED-WRONG / GOLDEN-ONLY / OURS-ONLY and
lists the one-sided sets.  MEASUREMENT ONLY."""
import sys, collections
def load(p):
    d = collections.Counter()
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln: continue
        k, _, rest = ln.partition(' => ')
        pay, _, n = rest.rpartition(' #')
        d[(k, pay)] += int(n)
    return d
g, o = load(sys.argv[1]), load(sys.argv[2])
gk = collections.Counter(); ok = collections.Counter()
for (k, p), n in g.items(): gk[k] += n
for (k, p), n in o.items(): ok[k] += n
same = moved = 0
movedrows = []
for (k, p), n in g.items():
    m = min(n, o[(k, p)]); same += m
for k in gk:
    if k in ok:
        common = min(gk[k], ok[k])
        gp = {p: c for (kk, p), c in g.items() if kk == k}
        op = {p: c for (kk, p), c in o.items() if kk == k}
        ident = sum(min(c, op.get(p, 0)) for p, c in gp.items())
        d = common - ident
        if d > 0:
            moved += d
            movedrows.append((k, sorted(gp), sorted(op), d))
gonly = sum(max(0, gk[k] - ok.get(k, 0)) for k in gk)
oonly = sum(max(0, ok[k] - gk.get(k, 0)) for k in ok)
print("BOTH-SAME %d  MOVED-WRONG %d  GOLDEN-ONLY %d  OURS-ONLY %d" % (same, moved, gonly, oonly))
if len(sys.argv) > 3 and sys.argv[3] == '-v':
    for k, gp, op, d in sorted(movedrows):
        print("MOVED %s\n   G %s\n   O %s" % (k, gp, op))
    for k in sorted(gk):
        if gk[k] > ok.get(k, 0): print("GOLDEN-ONLY %s x%d" % (k, gk[k]-ok.get(k,0)))
    for k in sorted(ok):
        if ok[k] > gk.get(k, 0): print("OURS-ONLY   %s x%d" % (k, ok[k]-gk.get(k,0)))
