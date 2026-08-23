# vbuvm31 verifier — VIEW-GENERAL three-way multiset scorer.
# Unlike cmp31.py (which concatenates the two views into one bag), this keys
# EVERY cell on (VIEW, loc, kind, arrayType, name, home) so a DEF-only or an
# ELAB-only move cannot hide inside the other view's rows, and it reports the
# vpiParent column as an informational split.
#   vcmp31.py <workdir>   -- reads cen.{g,pris,pat}.{def,elab}.txt
import collections, sys
W = sys.argv[1]
def load(f, view):
    d = collections.defaultdict(list)
    try:
        fh = open(f)
    except OSError:
        return d
    for line in fh:
        p = line.rstrip('\n').split('\t')
        if len(p) < 10: continue
        d[(view, p[2], p[3], p[4], p[5], p[6])].append((p[7], p[8], p[9]))
    return d
G = {}; O = {}; P = {}
for v in ('def', 'elab'):
    for tgt, nm in ((G, 'g'), (O, 'pris'), (P, 'pat')):
        tgt.update(load('%s/cen.%s.%s.txt' % (W, nm, v), v))
buckets = collections.defaultdict(list)
eq = 0
for k in sorted(set(G) | set(O) | set(P)):
    g = sorted(x[0] for x in G.get(k, []))
    o = sorted(x[0] for x in O.get(k, []))
    p = sorted(x[0] for x in P.get(k, []))
    ge = sorted(x[1] for x in G.get(k, []))
    oe = sorted(x[1] for x in O.get(k, []))
    pe = sorted(x[1] for x in P.get(k, []))
    if g == o == p:
        eq += 1
        if ge != pe: buckets['PARENT-ONLY-MOVE(judge-blind)'].append((k, ge, oe, pe))
        continue
    if g != o and g == p: buckets['FIXED'].append((k, g, o, p))
    elif g == o and g != p: buckets['MOVED-WRONG'].append((k, g, o, p))
    elif o == p: buckets['UNCHANGED-UNEQUAL'].append((k, g, o, p))
    else: buckets['MOVED-STILL-UNEQUAL'].append((k, g, o, p))
print("EQUAL-BOTH:", eq)
for b in ('FIXED', 'MOVED-WRONG', 'MOVED-STILL-UNEQUAL', 'UNCHANGED-UNEQUAL',
          'PARENT-ONLY-MOVE(judge-blind)'):
    rows = buckets.get(b, [])
    print("%s: %d" % (b, len(rows)))
    for k, g, o, p in rows:
        print("    ", k)
        print("       G:", g)
        print("       O:", o)
        print("       P:", p)
