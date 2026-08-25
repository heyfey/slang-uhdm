#!/usr/bin/env python3
"""r10earl94 — CELL-LEVEL verdict between a PRISTINE and a PATCHED census
against the same golden.  Every (key,payload) row that changed count is
classified; bucket counts can hide a swap, cells cannot.  MEASUREMENT ONLY."""
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
G, O, Q = (load(a) for a in sys.argv[1:4])
gkeys = collections.defaultdict(collections.Counter)
for (k, p), n in G.items(): gkeys[k][p] += n
def score(D):
    """per key: how many cells carry a payload golden also carries"""
    r = collections.Counter()
    dk = collections.defaultdict(collections.Counter)
    for (k, p), n in D.items(): dk[k][p] += n
    for k, pc in dk.items():
        gp = gkeys.get(k)
        if gp is None:
            r[('NOGOLD', k)] = sum(pc.values()); continue
        right = sum(min(c, gp.get(p, 0)) for p, c in pc.items())
        r[('RIGHT', k)] = right
        r[('TOT', k)] = sum(pc.values())
    return r
so, sq = score(O), score(Q)
w2r = r2w = 0; away = []; nogold = []
keys = set(k for (t, k) in list(so) + list(sq) if not k.startswith("GA|"))
for k in keys:
    ro, rq = so.get(('RIGHT', k), 0), sq.get(('RIGHT', k), 0)
    to, tq = so.get(('TOT', k), 0), sq.get(('TOT', k), 0)
    ngo, ngq = so.get(('NOGOLD', k), 0), sq.get(('NOGOLD', k), 0)
    if ngo or ngq:
        if ngo != ngq or True:
            po = {p: c for (kk, p), c in O.items() if kk == k}
            pq = {p: c for (kk, p), c in Q.items() if kk == k}
            if po != pq: nogold.append((k, po, pq))
        continue
    if rq > ro: w2r += rq - ro
    if rq < ro: r2w += ro - rq
    if to != tq: away.append((k, to, tq))
print("WRONG->RIGHT %d  RIGHT->WRONG %d  cellcount-changed %d  no-golden-key-changed %d"
      % (w2r, r2w, len(away), len(nogold)))
for k, a, b in away: print("  CELLCOUNT %s  %d -> %d" % (k, a, b))
for k, a, b in nogold: print("  NOGOLDENKEY %s\n    O %s\n    Q %s" % (k, a, b))
