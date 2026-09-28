#!/usr/bin/env python3
"""r11u200: span table of typespec / variable objects in two uhdm-dump outputs (order-blind).
usage: spantab.py <case dir> <golden dump> <ours dump> [type regex]
Prints, per (type, line, col) key present in either dump with a differing endcol set, the
source text each side's span covers. Reads only the case's own dut.sv."""
import re, sys, collections
case, gd, od = sys.argv[1:4]
tre = re.compile(sys.argv[4] if len(sys.argv) > 4 else r'(_typespec|_var)$')
src = open(case + '/dut.sv').read().split('\n')
pat = re.compile(r'^[\s|\\_]*([a-z_]+): ?(\([^)]*\)|[^,]*),.*?line:(\d+):(\d+), endln:(\d+):(\d+)')
def load(p):
    d = collections.defaultdict(collections.Counter)
    seen = set()
    for l in open(p, errors='replace'):
        m = pat.match(l)
        if not m or not tre.search(m.group(1)): continue
        t, nm, a, b, c, e = m.group(1), m.group(2), *map(int, m.groups()[2:])
        idm = re.search(r'id:(\d+)', l)
        # the dump prints an object at its def and at every reference; count distinct ids
        key = (t, a, b)
        oid = idm.group(1) if idm else l
        if (key, oid) in seen: continue
        seen.add((key, oid)); d[key][(c, e)] += 1
    return d
G, O = load(gd), load(od)
def txt(a, b, c, e):
    if a == c and 0 < a <= len(src): return src[a-1][b-1:e-1]
    return '<%d:%d-%d:%d>' % (a, b, c, e)
for k in sorted(set(G) | set(O), key=lambda k: (k[1], k[2], k[0])):
    if G.get(k) == O.get(k): continue
    t, a, b = k
    g = ' | '.join('%r x%d' % (txt(a, b, c, e), n) for (c, e), n in sorted(G.get(k, {}).items()))
    o = ' | '.join('%r x%d' % (txt(a, b, c, e), n) for (c, e), n in sorted(O.get(k, {}).items()))
    print('%-20s %4d:%-3d golden %-40s ours %s' % (t, a, b, g, o))
