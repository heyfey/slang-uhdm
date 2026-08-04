#!/usr/bin/env python3
"""cmpcsv.py <baseline.csv> <new.csv> [--dump]
Row-by-row status compare keyed on (name, mode).  Prints only changes."""
import csv, sys

def load(p):
    out = {}
    with open(p) as f:
        for row in csv.DictReader(f):
            out[(row['name'], row['mode'])] = row
    return out

a = load(sys.argv[1])
b = load(sys.argv[2])
want_dump = '--dump' in sys.argv
chg = 0
for k in sorted(set(a) | set(b)):
    ra, rb = a.get(k), b.get(k)
    if ra is None:
        print('  ONLY-NEW  %-40s %-10s %s' % (k[0], k[1], rb['status'])); chg += 1; continue
    if rb is None:
        print('  ONLY-BASE %-40s %-10s %s' % (k[0], k[1], ra['status'])); chg += 1; continue
    if ra['status'] != rb['status']:
        print('  STATUS    %-40s %-10s %s -> %s' % (k[0], k[1], ra['status'], rb['status'])); chg += 1
    elif want_dump and ra.get('dump') != rb.get('dump'):
        print('  DUMP      %-40s %-10s %s -> %s' % (k[0], k[1], ra.get('dump'), rb.get('dump'))); chg += 1
print('changes: %d' % chg)
