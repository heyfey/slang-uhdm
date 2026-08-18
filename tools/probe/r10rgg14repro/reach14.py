#!/usr/bin/env python3
"""r10rgg14/reach14.py — the PREDICTOR'S REACH: how many databases in a workdir
contain the object shape predict14.py keys on at all.  A predictor that reports
0 movers must first be shown to SEE the objects it screens."""
import os, sys, importlib.util
src = open(os.path.join(os.path.dirname(__file__), 'predict14.py')).read().split('def main()')[0]
g = {}; exec(src, g); hcidx = g['hcidx']
wd = sys.argv[1]
dbs = objs = withobj = 0
for mode in sorted(os.listdir(wd)):
    md = os.path.join(wd, mode)
    if not os.path.isdir(md): continue
    for t in sorted(os.listdir(md)):
        f = os.path.join(md, t, 'slang.uhdm')
        if not os.path.isfile(f): continue
        dbs += 1
        r = hcidx(f) or []
        if r: withobj += 1; objs += len(r)
print('databases=%d with-HighConn-bitselect-index=%d objects=%d' % (dbs, withobj, objs))
