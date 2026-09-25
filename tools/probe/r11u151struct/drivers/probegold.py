#!/usr/bin/env python3
"""probegold.py <rel> ...: print the cached golden path of each tests/probe case (check_probe's cache key)."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
WT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(WT, 'scripts'))
import check_probe as cp, verify_golden as vg
for rel in sys.argv[1:]:
    hit = vg.cache_load(cp.cache_dir(rel))
    print(rel, hit[1] if hit else 'MISS')
