#!/usr/bin/env python3
"""pgold.py <rel case path under tests/probe>...: the cached golden database of each probe case."""
import sys, os, glob
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../scripts'))
import check_probe as cp
for rel in sys.argv[1:]:
    d = cp.cache_dir(rel)
    g = glob.glob(os.path.join(d, '**', '*.uhdm'), recursive=True)
    print(g[0] if g else 'NONE')
