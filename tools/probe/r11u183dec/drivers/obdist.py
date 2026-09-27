#!/usr/bin/env python3
"""r11u183: order-blind record distance of one pair (uhdm-strictcmp --dump-a/-b files), depth column dropped.
usage: obdist.py <a.rec> <b.rec> -> 'dist=<ours-not-in-golden> rev=<golden-not-in-ours> total=<sum>'"""
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
d, r = sum((b - a).values()), sum((a - b).values())
print(f'dist={d} rev={r} total={d+r}')
