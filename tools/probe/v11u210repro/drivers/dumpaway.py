#!/usr/bin/env python3
"""v11u210: order-blind uhdm-dump line census of a case's two databases against golden.
usage: dumpaway.py [--flat] <g.dump> <pris.dump> <law.dump>   (--flat: leading tree bars and indentation dropped,
so a line matches golden at any depth: the census for pairs whose trees differ structurally)
Each dump line is normalised (ids dropped, leading bars kept); multisets.
LOST   = lines golden and pristine share that the law binary no longer writes (moved away from golden)
GAINED = lines golden and the law binary share that pristine did not write (moved toward golden)
prints: lost=<n> gained=<n> removed=<n> added=<n> and the lost / added-not-in-golden lines."""
import re, sys
from collections import Counter
FLAT = '--flat' in sys.argv
args = [a for a in sys.argv[1:] if a != '--flat']
def load(p):
    c = Counter()
    for l in open(p, errors='replace'):
        l = re.sub(r', id:\d+', '', l.rstrip('\n'))
        if FLAT: l = re.sub(r'^[ |\\_]*', '', l)
        l = re.sub(r'id:\d+', '', l)
        c[l] += 1
    return c
g, p, l = (load(x) for x in args[:3])
lost = Counter({k: min(g[k], p[k]) - min(g[k], l[k]) for k in p if min(g[k], p[k]) > min(g[k], l[k])})
gained = Counter({k: min(g[k], l[k]) - min(g[k], p[k]) for k in l if min(g[k], l[k]) > min(g[k], p[k])})
removed = p - l; added = l - p
print(f"lost={sum(lost.values())} gained={sum(gained.values())} removed={sum(removed.values())} added={sum(added.values())} added_not_golden={sum((added - g).values())}")
for k, v in list(lost.items())[:15]: print(f"  LOST {v} {k}")
for k, v in list((added - g).items())[:15]: print(f"  ADD-NOT-GOLDEN {v} {k}")
