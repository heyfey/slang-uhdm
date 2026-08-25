#!/usr/bin/env python3
"""r10earl94 — CELL-LEVEL corpus verdict: pristine vs patched against the SAME
golden, over the whole fixed universe.  Bucket counts can hide a swap; cells
cannot.  The GA family (the global tripwire) is scored separately.
MEASUREMENT ONLY."""
import sys, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln: continue
        tag, _, rest = ln.partition('\t')
        k, _, r2 = rest.partition(' => ')
        pay, _, n = r2.rpartition(' #')
        d[(tag, k)][pay] += int(n)
    return d
G, O, Q = (load(a) for a in sys.argv[1:4])
w2r = r2w = 0; nog = []; ga = []
for key in set(O) | set(Q):
    if key[1].startswith('GA|'):
        if O.get(key) != Q.get(key): ga.append((key, dict(O.get(key, {})), dict(Q.get(key, {}))))
        continue
    gp = G.get(key)
    op, qp = O.get(key, collections.Counter()), Q.get(key, collections.Counter())
    if op == qp: continue
    if gp is None:
        nog.append((key, dict(op), dict(qp))); continue
    ro = sum(min(c, gp.get(p, 0)) for p, c in op.items())
    rq = sum(min(c, gp.get(p, 0)) for p, c in qp.items())
    if rq > ro: w2r += rq - ro
    if rq < ro: r2w += ro - rq
print("WRONG->RIGHT %d  RIGHT->WRONG %d  no-golden-key-changed %d  GA-buckets-changed %d"
      % (w2r, r2w, len(nog), len(ga)))
for k, a, b in nog: print("  NOGOLDENKEY %s %s\n    O %s\n    Q %s" % (k[0], k[1], a, b))
for k, a, b in ga: print("  GA %s %s  O %s -> Q %s" % (k[0], k[1], a, b))
