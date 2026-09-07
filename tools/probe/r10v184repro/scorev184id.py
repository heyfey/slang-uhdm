#!/usr/bin/env python3
"""r10v184 — the IDENTITY-GRANULARITY scorer.  MEASUREMENT ONLY.

`r10uvm184repro/score184.py` scores the argument binding with a THREE-VALUED
verdict (BARE / OTHER / SAME-AS-RECEIVER).  Two different non-receiver bindings
therefore both read `OTHER`, so a move BETWEEN two wrong objects is invisible to
it.  This scorer keys on the same id-free key but takes the value to be the
ACTUAL's own face (`kind(name)@line:col`), so every move is visible.

    scorev184id.py <golden.mfc> <pristine.mfc> <patched.mfc>

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
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
            if len(f) < 8:
                continue
            # ... arg<N> m=<meth> fn=<0|1> <ACTFACE> recv=<...> <VERDICT>
            act = f[7]
            rows[(f[0], f[1], f[2], f[3], f[4])].append(act)
    return {k: tuple(sorted(v)) for k, v in rows.items()}


def main():
    g, a, b = (load(p) for p in sys.argv[1:4])
    c = Counter()
    detail = []
    for k in sorted(set(g) | set(a) | set(b)):
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
        if d[0] in ('AWAY', 'MOVED-WRONG', 'ONLY-OURS-MOVED', 'STILL-WRONG'):
            print('   ', d[0], d[1], 'G', d[2], 'A', d[3], 'B', d[4])


if __name__ == '__main__':
    main()
