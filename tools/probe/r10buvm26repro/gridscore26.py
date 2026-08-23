#!/usr/bin/env python3
"""r10buvm26 — THREE-WAY grid scorer: golden vs pristine vs patched.

MEASUREMENT ONLY; the official `uhdm-cmp` is the judge.  LHS is ALWAYS golden.

Scores every SOURCE LINE of a grid as a MULTISET of compare-visible object
rows (see gridcen26.py for the row shape), so a change in MULTIPLICITY cannot
hide and a last-writer dict cannot drop a colliding key.

    FIXED         pristine != golden, patched == golden
    BROKEN        pristine == golden, patched != golden      <- must be 0
    STILL-WRONG   both differ from golden
    STILL-RIGHT   both equal golden

usage: gridscore26.py <golden.dump> <pristine.dump> <patched.dump> [--full]
"""
import collections
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from gridcen26 import rows        # noqa: E402


def bucket(path, full):
    d = collections.defaultdict(collections.Counter)
    for r in rows(path, full):
        d[r.split(' ', 1)[0]][r] += 1
    return d


def main():
    full = '--full' in sys.argv
    g, p, q = (bucket(sys.argv[i], full) for i in (1, 2, 3))
    lines = sorted(set(g) | set(p) | set(q),
                   key=lambda x: (x == '-', int(x) if x.isdigit() else 0))
    fixed, broken, sw, sr = [], [], [], []
    for ln in lines:
        gg, pp, qq = g.get(ln, {}), p.get(ln, {}), q.get(ln, {})
        okp, okq = gg == pp, gg == qq
        (sr if okp and okq else fixed if okq else broken if okp else sw
         ).append(ln)
    print('CELLS %d  FIXED %d  BROKEN %d  STILL-WRONG %d  STILL-RIGHT %d'
          % (len(lines), len(fixed), len(broken), len(sw), len(sr)))
    print('FIXED       : ' + ','.join(fixed))
    print('BROKEN      : ' + ','.join(broken))
    print('STILL-WRONG : ' + ','.join(sw))


if __name__ == '__main__':
    main()
