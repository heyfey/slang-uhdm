#!/usr/bin/env python3
"""r10uvm215 — the MODPORT CENSUS join.  MEASUREMENT ONLY; the official
uhdm-cmp is the sole judge.  LHS is ALWAYS golden, RHS is ALWAYS ours.

Reads two flat key files produced by `ct215mpcen` and joins them as MULTISETS
(RESUME §9: a last-writer dict silently drops colliding rows, and keys DO
collide here — two instances of the same interface produce the same key).

Prints every ONLY-GOLDEN and ONLY-OURS line, then the one-line verdict the grid
and the boundary read:

    AGREE=<n> ONLY-GOLDEN=<n> ONLY-OURS=<n>

A golden-vs-golden calibration must read ONLY-GOLDEN=0 ONLY-OURS=0.
"""
import collections
import sys


def load(path):
    c = collections.Counter()
    with open(path) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line or line.startswith('RESTORE_FAIL'):
                if line.startswith('RESTORE_FAIL'):
                    c['RESTORE_FAIL'] += 1
                continue
            c[line] += 1
    return c


def main():
    g = load(sys.argv[1])
    o = load(sys.argv[2])
    only_g = g - o
    only_o = o - g
    for k in sorted(only_g):
        for _ in range(only_g[k]):
            print('ONLY-GOLDEN ' + k)
    for k in sorted(only_o):
        for _ in range(only_o[k]):
            print('ONLY-OURS   ' + k)
    agree = sum((g & o).values())
    print('AGREE=%d ONLY-GOLDEN=%d ONLY-OURS=%d' %
          (agree, sum(only_g.values()), sum(only_o.values())))


main()
