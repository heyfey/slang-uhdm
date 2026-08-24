#!/usr/bin/env python3
# r10earl79 — 3-way multiset scorer over rngcen79 lines.  JUDGE FIELDS ONLY:
# everything before " || SPANS:" (constant::Compare reads VpiType/VpiName/
# VpiDefName, VpiDecompile, VpiSize, Typespec, VpiConstType — never a span).
# A separate SPAN tally is reported for information, never for scoring.
import sys, collections
def load(p, judge=True):
    c = collections.Counter()
    for l in open(p):
        l = l.rstrip('\n')
        k = l.split(' || SPANS:')[0] if judge else l
        c[k] += 1
    return c
g, o, q = (load(sys.argv[i]) for i in (1, 2, 3))
keys = set(g) | set(o) | set(q)
tog = away = movedwrong = still = same = 0
for k in keys:
    G, O, Q = g[k], o[k], q[k]
    if O == Q:
        if G != O: still += min(1, abs(G-O))
        continue
for k in keys:
    G, O, Q = g[k], o[k], q[k]
    if O == Q: continue
    d = Q - O
    if d > 0:
        if G > O: tog += min(d, G-O)
        else:     movedwrong += d if G <= O else 0
    else:
        if G < O: tog += min(-d, O-G)
        else:     away += -d
print("cells golden=%d pris=%d patched=%d" % (sum(g.values()), sum(o.values()), sum(q.values())))
print("TO-GOLDEN=%d AWAY-GOLDEN=%d MOVED-WRONG=%d" % (tog, away, movedwrong))
dg_o = sum((g-o).values()) + sum((o-g).values())
dg_q = sum((g-q).values()) + sum((q-g).values())
print("multiset distance golden<->pristine=%d  golden<->patched=%d" % (dg_o, dg_q))
sg, so, sq = (load(sys.argv[i], False) for i in (1,2,3))
print("WITH SPANS: distance golden<->pristine=%d  golden<->patched=%d" % (
    sum((sg-so).values())+sum((so-sg).values()),
    sum((sg-sq).values())+sum((sq-sg).values())))
