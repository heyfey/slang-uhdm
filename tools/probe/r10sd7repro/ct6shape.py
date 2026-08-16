#!/usr/bin/env python3
"""r10sd6 — PER-SHAPE MOVERS BY MULTISET, ADDED and REMOVED SEPARATELY.

The standing mover rule forbids reporting a net line-count: a change that adds
370 `vpiFullName` lines and removes 370 others nets to zero and reads as "no
change".  So every measurement here is a MULTISET difference, and the two
directions are never summed:

    ADDED[shape]   = sum over lines of that shape of max(0, new - old)
    REMOVED[shape] = sum over lines of that shape of max(0, old - new)

and, separately, the DISTANCE TO GOLDEN per shape, before and after, so a change
that moves bytes AWAY from golden cannot hide inside a total that improves.

A line's SHAPE is its leading token: the object kind (`\\_class_var: ...`) or the
field name (`|vpiFullName:...`).  The rest of the line is part of the multiset
KEY, not of the shape — indentation included, because uhdm-dump encodes depth as
leading spaces (the whitespace-blindness defect r10uvm57 found in msdist.sh).

  usage: ct6shape.py <golden.dump> <old.dump> <new.dump>

All three inputs must already have uhdm-dump's first line (the database path)
stripped.  GUARD: a missing or empty input is a hard error, never a distance
of 0.
"""
import collections
import os
import re
import sys

SHAPE = re.compile(r'^\s*(?:\\_([A-Za-z_0-9]+):|\|([A-Za-z_0-9]+):)')


def load(path):
    if not os.path.exists(path) or os.path.getsize(path) == 0:
        sys.exit('NO_OUTPUT: missing or empty %s' % path)
    c = collections.Counter()
    with open(path, 'rt', errors='replace') as fh:
        for line in fh:
            c[line.rstrip('\n')] += 1
    return c


def shape_of(line):
    m = SHAPE.match(line)
    if not m:
        return '<other>'
    return m.group(1) or m.group(2)


def per_shape_delta(a, b):
    """max(0, b-a) per line, bucketed by shape."""
    out = collections.Counter()
    for k, n in b.items():
        d = n - a.get(k, 0)
        if d > 0:
            out[shape_of(k)] += d
    return out


def main():
    g, o, n = (load(p) for p in sys.argv[1:4])
    added = per_shape_delta(o, n)
    removed = per_shape_delta(n, o)
    print('== ADDED / REMOVED (delivered vs pristine), per shape, by MULTISET')
    shapes = sorted(set(added) | set(removed),
                    key=lambda s: -(added[s] + removed[s]))
    for s in shapes:
        print('  %-24s ADDED %-7d REMOVED %-7d' % (s, added[s], removed[s]))
    print('  %-24s ADDED %-7d REMOVED %-7d' %
          ('TOTAL', sum(added.values()), sum(removed.values())))

    def dist(x):
        d = collections.Counter()
        for k, c in g.items():
            v = c - x.get(k, 0)
            if v > 0:
                d[shape_of(k)] += v
        for k, c in x.items():
            v = c - g.get(k, 0)
            if v > 0:
                d[shape_of(k)] += v
        return d

    do, dn = dist(o), dist(n)
    imp = wor = same = 0
    rows = []
    for s in sorted(set(do) | set(dn)):
        if dn[s] < do[s]:
            imp += 1
        elif dn[s] > do[s]:
            wor += 1
        else:
            same += 1
            continue
        rows.append((dn[s] - do[s], s, do[s], dn[s]))
    print('== DISTANCE TO GOLDEN per shape (pristine -> delivered)')
    for delta, s, a, b in sorted(rows):
        print('  %-24s %7d -> %-7d  %+d' % (s, a, b, delta))
    print('  shapes IMPROVED %d  WORSENED %d  unchanged %d' % (imp, wor, same))
    print('  TOTAL %d -> %d  (%+d)' %
          (sum(do.values()), sum(dn.values()),
           sum(dn.values()) - sum(do.values())))


main()
