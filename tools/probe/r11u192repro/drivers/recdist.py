#!/usr/bin/env python3
import sys, collections
# recdist.py <A.txt golden records> <B.txt ours before> <C.txt ours after>: order-blind canonical record distance
def load(p):
    return collections.Counter(l.rstrip('\n').split('\t',1)[1] for l in open(p) if '\t' in l)
g=load(sys.argv[1]); b=load(sys.argv[2]); a=load(sys.argv[3])
d=lambda x: sum(((x-g)+(g-x)).values())
db,da=d(b),d(a)
print('canon before=%d after=%d %s'%(db,da,'TOWARD' if da<db else 'AWAY' if da>db else 'SAME'))
