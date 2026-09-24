#!/usr/bin/env python3
"""dsdiff.py base.csv new.csv — row-join two downstream csvs on name; prints every verdict/differs change."""
import csv, sys
def load(p):
    return {r['name']: r for r in csv.DictReader(open(p))}
a, b = load(sys.argv[1]), load(sys.argv[2])
n = 0
for t in sorted(set(a) | set(b)):
    ra, rb = a.get(t), b.get(t)
    va = (ra['verdict'], ra['differs']) if ra else ('ABSENT', '')
    vb = (rb['verdict'], rb['differs']) if rb else ('ABSENT', '')
    if va != vb:
        n += 1
        print(t, va, '->', vb)
print('changed', n, 'of', len(set(a) | set(b)))
