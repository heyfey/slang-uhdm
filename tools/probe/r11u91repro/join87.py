#!/usr/bin/env python3
"""r11u87 ROW JOIN — a committed baseline CSV against a sweep of this pass's
own, keyed on (name, mode), every field compared.  Prints ONLY-BASE / ONLY-NEW
and every differing field, and a DIFF= count; `DIFF=0` is the gate.

usage: join87.py <baseline.csv> <new.csv> [<new2.csv> ...]
"""
import csv
import sys


def load(paths):
    rows = {}
    for p in paths:
        with open(p, newline='') as f:
            for r in csv.DictReader(f):
                rows[(r['name'], r['mode'])] = r
    return rows


def main():
    base = load([sys.argv[1]])
    new = load(sys.argv[2:])
    n = 0
    for k in sorted(set(base) | set(new)):
        b, x = base.get(k), new.get(k)
        if b is None:
            print('ONLY-NEW  %s' % (k,))
            n += 1
            continue
        if x is None:
            print('ONLY-BASE %s' % (k,))
            n += 1
            continue
        d = [f for f in b if b[f] != x.get(f)]
        if d:
            print('FIELD %-40s %s' % ('/'.join(k), ' '.join(
                '%s: %r -> %r' % (f, b[f], x.get(f)) for f in d)))
            n += 1
    print('rows base=%d new=%d DIFF=%d' % (len(base), len(new), n))
    return 0


sys.exit(main())
