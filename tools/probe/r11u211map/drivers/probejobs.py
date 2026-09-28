#!/usr/bin/env python3
"""Probe job list: every tests/probe case, golden = the check_probe cache entry,
ours = <probe workdir>/<rel with / -> __>.uhdm. Args: <repo> <probe workdir> <out.tsv>.
Run with the SURELOG env of the pins (the cache key reads Surelog's version line)."""
import os, sys
repo, wd, out = sys.argv[1:4]
sys.path.insert(0, os.path.join(repo, 'scripts'))
import check_probe as cp
n = miss = 0
with open(out, 'w') as f:
    for rel in cp.cases(None):
        g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
        o = os.path.join(wd, rel.replace('/', '__') + '.uhdm')
        if not (os.path.exists(g) and os.path.exists(o)):
            miss += 1; print('MISS', rel, os.path.exists(g), os.path.exists(o)); continue
        f.write('\t'.join(['probe', 'default', rel.replace('/', '__'), g, o, rel]) + '\n'); n += 1
print('probe jobs', n, 'missing', miss)
