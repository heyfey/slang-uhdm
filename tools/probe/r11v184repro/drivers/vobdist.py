#!/usr/bin/env python3
# vobdist.py <golden.dump> <before.dump> <after.dump>: order-blind multiset distance (dump lines, ids and paths stripped)
import sys, collections, re
def load(p):
    c = collections.Counter()
    for l in open(p, errors='replace'):
        l = re.sub(r', id:\d+', '', l.rstrip('\n'))
        l = re.sub(r'file:\S*/', 'file:', l)
        l = re.sub(r'\S*/([^/\s]+\.uhdm)', r'\1', l)
        c[l] += 1
    return c
g, b, a = (load(p) for p in sys.argv[1:4])
def dist(x): return sum(((x - g) + (g - x)).values())
db, da = dist(b), dist(a)
print('%d->%d %s' % (db, da, 'TOWARD' if da < db else 'AWAY' if da > db else 'SAME'))
