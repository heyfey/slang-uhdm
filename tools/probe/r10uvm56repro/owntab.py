#!/usr/bin/env python3
"""Cross-tab retown output: (vpiMethod, has-class-parent) x refs/bound.
    owntab.py <label> <g.own> <o.own>
"""
import re
import sys
from collections import defaultdict


def rows(p):
    out = []
    for ln in open(p):
        r = int(re.search(r'refs= *(\d+)', ln).group(1))
        b = int(re.search(r'bound= *(\d+)', ln).group(1))
        m = int(re.search(r'method=(\d+)', ln).group(1))
        cls = re.search(r'cls=(\S+)', ln).group(1)
        cp = int(re.search(r'clsParams=(-?\d+)', ln).group(1))
        au = int(re.search(r'automatic=(\d+)', ln).group(1))
        fn = ln.split('|')[2].strip()
        view = ln.split('|')[1].strip()
        out.append((view, fn, r, b, m, cls, cp, au))
    return out


label = sys.argv[1]
print('==== %s' % label)
for side, path in (('golden', sys.argv[2]), ('ours  ', sys.argv[3])):
    agg = defaultdict(lambda: [0, 0, 0])
    for view, fn, r, b, m, cls, cp, au in rows(path):
        key = 'vpiMethod=%d %s' % (m, 'inClass' if cls != '-' else 'noClass')
        a = agg[key]
        a[0] += 1
        a[1] += r
        a[2] += b
    for k in sorted(agg):
        f, r, b = agg[k]
        print('  %s  %-24s funcs=%3d retNameRefs=%4d BOUND=%4d' % (side, k, f, r, b))
