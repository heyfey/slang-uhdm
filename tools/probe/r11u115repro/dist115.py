#!/usr/bin/env python3
# dist113.py <gold.dump> <A.dump> <B.dump>: ORDER-BLIND whole-dump distance to golden, A and B.
# Lines are path-normalised (ids, /tmp paths, file: fields dropped), the multiset difference
# |gold - X| + |X - gold| is the distance.  Also the range-bound-constant cell score (rbc113).
import sys, re, collections
def norm(p):
    c = collections.Counter()
    for l in open(p, errors='replace').read().split('\n')[1:]:
        l = re.sub(r', id:\d+', '', l); l = re.sub(r'file:[^,]*,', '', l); l = re.sub(r'/tmp/[^ ,)]*', '<P>', l)
        c[l] += 1
    return c
g, a, b = (norm(x) for x in sys.argv[1:4])
da = sum(((g - a) + (a - g)).values()); db = sum(((g - b) + (b - g)).values())
print(f'dist {da}->{db}')
