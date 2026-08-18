#!/usr/bin/env python3
"""r10earl62 — MULTISET JOIN of two cacen62 censuses (golden vs ours).

LHS IS ALWAYS GOLDEN.  Keys are (section, owner defname, ca line:col,
positional path, ref kind:name); the VALUE is the Actual kind(name).  A key
can occur N times (N elaborated copies) — this is a MULTISET join, never a
last-writer dict (RESUME §9 census traps).

Prints, per (key,value) cell, golden count vs ours count, bucketed:
  MISSING   golden binds, we do not (value '-()' on our side or absent)
  EXTRA     we bind, golden does not
  DIFFKIND  both bind, different Actual kind/name
"""
import sys, collections

def load(p):
    c = collections.Counter()
    for l in open(p, errors='replace'):
        l = l.rstrip('\n')
        if not l.startswith('CA '): continue
        key, _, val = l.partition(' = ')
        c[(key, val)] += 1
    return c

g, o = load(sys.argv[1]), load(sys.argv[2])
# regroup by key
gk = collections.defaultdict(collections.Counter)
ok = collections.defaultdict(collections.Counter)
for (k, v), n in g.items(): gk[k][v] += n
for (k, v), n in o.items(): ok[k][v] += n

buckets = collections.Counter()
rows = []
for k in set(gk) | set(ok):
    gv, ov = gk.get(k, collections.Counter()), ok.get(k, collections.Counter())
    if gv == ov: continue
    for v in set(gv) | set(ov):
        d = ov[v] - gv[v]
        if d == 0: continue
        rows.append((k, v, gv[v], ov[v]))
NOACT = '-()'
agg = collections.Counter()
for k, v, gn, on in rows:
    if v == NOACT:
        tag = 'OURS-NULL' if on > gn else 'GOLDEN-NULL'
    else:
        tag = 'OURS-BINDS' if on > gn else 'GOLDEN-BINDS'
    kind = v.split('(')[0]
    agg[(tag, kind)] += abs(on - gn)
print('=== cells by (direction, actual kind) ===')
for (t, kd), n in sorted(agg.items(), key=lambda x: -x[1]):
    print('  %-12s %-24s %d' % (t, kd, n))
print('=== top differing keys (golden count / ours count) ===')
rows.sort(key=lambda r: -abs(r[3]-r[2]))
lim = int(sys.argv[3]) if len(sys.argv) > 3 else 60
for k, v, gn, on in rows[:lim]:
    print('  g=%-4d o=%-4d %s = %s' % (gn, on, k[3:], v))
print('TOTAL differing (key,value) cells:', len(rows))
