#!/usr/bin/env python3
"""r10uvm13cmp.py <baseline.csv> <new.csv> — status+dump deltas, keyed name|mode."""
import sys, csv

def load(p):
    d = {}
    with open(p) as f:
        for r in csv.reader(f):
            if not r or r[0] == "name":
                continue
            d[(r[0], r[1])] = (r[2], r[5] if len(r) > 5 else "")
    return d

a, b = load(sys.argv[1]), load(sys.argv[2])
onlyA = sorted(set(a) - set(b))
onlyB = sorted(set(b) - set(a))
chg = []
for k in sorted(set(a) & set(b)):
    if a[k] != b[k]:
        chg.append((k, a[k], b[k]))
print("baseline=%d new=%d only-in-baseline=%d only-in-new=%d changed=%d"
      % (len(a), len(b), len(onlyA), len(onlyB), len(chg)))
for k in onlyA[:20]:
    print("  MISSING  %s %s" % k)
for k in onlyB[:20]:
    print("  NEW      %s %s" % k)
for k, x, y in chg:
    print("  CHANGED  %-42s %-9s  %s/%s -> %s/%s" % (k[0], k[1], x[0], x[1], y[0], y[1]))
