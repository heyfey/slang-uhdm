#!/usr/bin/env python3
# censcore111.py <cen-dir> <tagA> [tagB]: per row and face (F1/F2/F3/F5/F6), the multiset distance
# |gold - tag| + |tag - gold| (census lines, dedupe-free Counter).  With tagB: rows where the two
# tags' distances differ, classed TO-GOLDEN / AWAY / MIXED per face.
import sys, os, collections
d, a = sys.argv[1], sys.argv[2]; b = sys.argv[3] if len(sys.argv) > 3 else None
def load(p):
    c = collections.defaultdict(collections.Counter)
    if not os.path.exists(p): return None
    for ln in open(p, errors='replace'):
        ln = ln.rstrip('\n')
        if ln: c[ln[:2]][ln] += 1
    return c
def dist(g, o, f):
    x, y = g.get(f, collections.Counter()), o.get(f, collections.Counter())
    return sum(((x - y) + (y - x)).values())
rows = sorted({fn.rsplit('.', 1)[0] for fn in os.listdir(d) if fn.endswith('.gold')})
tot = collections.Counter()
for r in rows:
    g = load(f'{d}/{r}.gold'); A = load(f'{d}/{r}.{a}')
    if g is None or A is None: continue
    for f in ('F1', 'F2', 'F3', 'F5', 'F6'):
        da = dist(g, A, f)
        if not b:
            if da: print(f'{r} {f} {a}={da}'); tot[f] += 1
            continue
        B = load(f'{d}/{r}.{b}')
        if B is None: continue
        db = dist(g, B, f)
        if A.get(f) != B.get(f):
            cls = 'TO-GOLDEN' if db < da else ('AWAY' if db > da else 'LATERAL')
            print(f'{r} {f} {a}={da} {b}={db} {cls}'); tot[(f, cls)] += 1
print('TOTAL', dict(tot))
