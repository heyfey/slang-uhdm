#!/usr/bin/env python3
"""r10v64 — span-keyed MULTISET score of a whole-design constant census.
Per KEY (span), compares the payload multisets: how many golden payloads the
pristine side matched vs the patched side.  TO-GOLDEN = keys where patched
matches more golden payloads than pristine did; AWAY = fewer."""
import sys, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        k, _, v = ln.rstrip('\n').partition('|')
        d[k][v] += 1
    return d
g, o, p = (load(x) for x in sys.argv[1:4])
def match(a, b):   # size of multiset intersection
    return sum(min(a[k], b[k]) for k in a)
to = aw = 0; tocells = awcells = 0
ex = []
for k in set(g) | set(o) | set(p):
    G, O, P = g.get(k, collections.Counter()), o.get(k, collections.Counter()), p.get(k, collections.Counter())
    mo, mp = match(G, O), match(G, P)
    # unmatched (wrong) counts, symmetric
    wo = (sum(G.values()) - mo) + (sum(O.values()) - mo)
    wp = (sum(G.values()) - mp) + (sum(P.values()) - mp)
    if wp < wo: to += 1; tocells += wo - wp
    elif wp > wo: aw += 1; awcells += wp - wo; ex.append((wp - wo, k, G, O, P))
print("KEYS_TOGOLDEN=%d (%d cells)  KEYS_AWAY=%d (%d cells)" % (to, tocells, aw, awcells))
ex.sort(reverse=True)
for d_, k, G, O, P in ex[:15]:
    print("AWAY +%d %s\n   G:%s\n   O:%s\n   P:%s" % (d_, k, dict(G), dict(O), dict(P)))
