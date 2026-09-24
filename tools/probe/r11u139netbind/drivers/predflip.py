#!/usr/bin/env python3
"""predflip.py <pred_dir>  (r11u139) — from predict.sh's refbind diffs, the rows whose golden/ours
difference is a BINDING difference: a reference (same name and span, multiset-matched) whose Actual is
a DEF-listing object on one side and an elaborated one on the other, or whose Actual kind or full name
differs.  Prints '<row> <flips> <fullname-only>' for every row with at least one."""
import sys, os, collections
d = sys.argv[1]
for f in sorted(os.listdir(d)):
    if not f.endswith('.diff'): continue
    L = collections.defaultdict(list); R = collections.defaultdict(list)
    for line in open(os.path.join(d, f), errors='replace'):
        if line[:2] not in ('< ', '> '): continue
        p = line[2:].rstrip('\n').split('\t')
        if len(p) < 4: continue
        key = (p[0], p[1])
        (L if line[0] == '<' else R)[key].append((p[2], ' '.join(p[3].split(' ')[:2])))
    flips = fn = 0
    for k in set(L) | set(R):
        a = sorted(L.get(k, [])); b = sorted(R.get(k, []))
        for x, y in zip(a, b):
            if x[1] != y[1]: flips += 1
            elif x[0] != y[0]: fn += 1
    if flips or fn:
        print(f[:-5], flips, fn)
