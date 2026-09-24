#!/usr/bin/env python3
"""linemap.py <g.rec> <ours.rec>: pair records in walk order and print the (file, our line -> golden line)
map for line and endline fields (only where the records otherwise agree on type/name)."""
import sys, collections
def load(p):
    return [l.rstrip('\n').split('\t') for l in open(p)]
a, b = load(sys.argv[1]), load(sys.argv[2])
m = collections.Counter()
for x, y in zip(a, b):
    if len(x) < 10 or len(y) < 10 or x[1] != y[1] or x[2] != y[2]: continue
    if x[5] != y[5] or not x[5]: continue
    for i in (6, 8):
        if y[i] != '0':
            m[(y[5], int(y[i]), int(x[i]))] += 1
for (f, o, g), n in sorted(m.items()):
    print(f'{f}\tours {o}\tgolden {g}\t{"" if o == g else "DIFF"}\t{n}')
