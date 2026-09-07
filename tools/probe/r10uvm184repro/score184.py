#!/usr/bin/env python3
"""r10uvm184 — the MULTISET scorer for the method-call argument binding.

MEASUREMENT ONLY; `uhdm-cmp` is the sole judge.  LHS is ALWAYS golden
(Surelog); RHS is ALWAYS ours.

    score184.py <golden.mfc> <pristine.mfc> <patched.mfc>

Reads three `ct184mfc` censuses and joins them as a MULTISET on the id-free,
span-free-on-the-ancestors key

    LISTING | SUBR | LINE:COL | NAME | ARGIDX

with the VERDICT column (BARE / OTHER / SAME-AS-RECEIVER) as the value.  A
dictionary keyed by name alone would drop the clone's copies (RESUME.md §9), so
the value is a sorted multiset of verdicts per key and every comparison is
between multisets.

Columns, all scored explicitly:

    TOWARD          pristine disagreed with golden, patched agrees
    AWAY            pristine AGREED with golden, patched does not   <- must be 0
    MOVED-WRONG     both disagree with golden and the patch changed the answer
    STILL-WRONG     both disagree and the patch did not touch it
    UNTOUCHED       patched == pristine and both agree with golden
    ONLY-GOLDEN     key absent from ours entirely (both binaries)
    ONLY-OURS       key absent from golden entirely (both binaries)

`ONLY-*` are reported for BOTH binaries so a key the patch invents or destroys
cannot hide inside them.
"""
import sys
from collections import defaultdict, Counter


def load(path):
    rows = defaultdict(list)
    with open(path) as fh:
        for ln in fh:
            if ln.startswith('ROWS'):
                continue
            f = ln.split()
            if len(f) < 6:
                continue
            rows[(f[0], f[1], f[2], f[3], f[4])].append(f[-1])
    return {k: tuple(sorted(v)) for k, v in rows.items()}


def main():
    g, a, b = (load(p) for p in sys.argv[1:4])
    keys = set(g) | set(a) | set(b)
    c = Counter()
    detail = []
    for k in sorted(keys):
        G, A, B = g.get(k), a.get(k), b.get(k)
        if G is None:
            c['ONLY-OURS-pristine' if A is not None else 'x'] += 0
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
