#!/usr/bin/env python3
"""r10uvm186 — the MULTISET scorer for the dynamic-array `new[...]` argument
binding.

MEASUREMENT ONLY; `uhdm-cmp` is the sole judge.  LHS is ALWAYS golden
(Surelog); RHS is ALWAYS ours.

    score186.py <golden.new> <pristine.new> <patched.new>

Reads three `ct186new` censuses and joins them as a MULTISET on the id-free,
span-free-on-the-ancestors key

    LISTING | LINE:COL | NAME | ARGIDX | DYN

with the ACTUAL's own FACE (`kind(name)@line:col`, or `BARE`) as the value —
IDENTITY granularity, not a three-valued verdict, so a move between two
different WRONG objects cannot hide (r10v184 §4 named that blind spot in the
predecessor's scorer).

The LISTING in that key is `ct186new`'s OWNER-INDEX walk, not a bare
`VpiParent` chain: the dynamic-array `new` call is UNPARENTED in every home
and elaborated listing, so a naive walk collapses all four listings of one
source line into a single bucket and a pre-existing residue in the elaborated
listing then reads as a MOVED-WRONG on the clone cell.  Measured: without the
owner index arm A scores MOVED-WRONG 14 / TOWARD 0; with it, TOWARD 14 /
MOVED-WRONG 0 and the elaborated residue is named separately as STILL-WRONG.

A wildcard-import clone is listed TWICE under one root, so the value stays a
MULTISET — a dictionary keyed by position alone drops the second copy
(RESUME §9).

Columns, all scored explicitly:

    TOWARD          pristine disagreed with golden, patched agrees
    AWAY            pristine AGREED with golden, patched does not   <- must be 0
    MOVED-WRONG     both disagree with golden and the patch changed the answer
    STILL-WRONG     both disagree and the patch did not touch it
    UNTOUCHED       patched == pristine and both agree with golden
    ONLY-GOLDEN     key absent from ours entirely (both binaries)
    ONLY-OURS       key absent from golden entirely (both binaries)
    ONLY-OURS-MOVED an ONLY-OURS key whose value the patch changed
"""
import sys
from collections import defaultdict, Counter


def load(path):
    rows = defaultdict(list)
    with open(path) as fh:
        for ln in fh:
            if ln.startswith('ROWS') or ln.startswith('RESTORE_FAIL'):
                continue
            f = ln.split()
            if len(f) < 6:
                continue
            rows[(f[0], f[1], f[2], f[3], f[4])].append(f[5])
    return {k: tuple(sorted(v)) for k, v in rows.items()}


def main():
    g, a, b = (load(p) for p in sys.argv[1:4])
    keys = set(g) | set(a) | set(b)
    c = Counter()
    detail = []
    for k in sorted(keys):
        G, A, B = g.get(k), a.get(k), b.get(k)
        if G is None:
            c['ONLY-OURS'] += 1
            if A != B:
                c['ONLY-OURS-MOVED'] += 1
                detail.append(('ONLY-OURS-MOVED', k, G, A, B))
            continue
        if A is None and B is None:
            c['ONLY-GOLDEN'] += 1
            continue
        if A == B:
            c['UNTOUCHED' if A == G else 'STILL-WRONG'] += 1
            if A != G:
                detail.append(('STILL-WRONG', k, G, A, B))
            continue
        if B == G:
            c['TOWARD'] += 1
            detail.append(('TOWARD', k, G, A, B))
        elif A == G:
            c['AWAY'] += 1
            detail.append(('AWAY', k, G, A, B))
        else:
            c['MOVED-WRONG'] += 1
            detail.append(('MOVED-WRONG', k, G, A, B))
    for name in ('TOWARD', 'AWAY', 'MOVED-WRONG', 'STILL-WRONG', 'UNTOUCHED',
                 'ONLY-GOLDEN', 'ONLY-OURS', 'ONLY-OURS-MOVED'):
        print(f'{name:18s} {c[name]}')
    for d in detail:
        print('   ', d[0], d[1], 'G', d[2], 'A', d[3], 'B', d[4])


if __name__ == '__main__':
    main()
