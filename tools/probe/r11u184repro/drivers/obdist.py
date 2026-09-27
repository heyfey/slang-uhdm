#!/usr/bin/env python3
# obdist.py <golden.dump> <before.dump> <after.dump>: order-blind multiset distance (lines) of each ours-dump to golden,
# and the verdict TOWARD / AWAY / SAME (uhdm-dump outputs; the workdir-normalised copies grid.sh writes)
import sys, collections, re
def load(p):
    c = collections.Counter()
    for l in open(p, errors='replace'):
        l = re.sub(r'/tmp/r11u184_g/\S*?/(gold/w/|)', 'W/', l.rstrip('\n'))
        c[l] += 1
    return c
g, b, a = (load(p) for p in sys.argv[1:4])
def dist(x): return sum(((x - g) + (g - x)).values())
db, da = dist(b), dist(a)
print('before=%d after=%d %s' % (db, da, 'TOWARD' if da < db else 'AWAY' if da > db else 'SAME'))
