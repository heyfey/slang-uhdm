#!/usr/bin/env python3
"""r10earl63 — 3-WAY SCORE of a pacen63 grid: golden vs PRISTINE vs PATCHED.

MEASUREMENT ONLY.  Prints, per key, whether the patch moved the cell
TO-GOLDEN, AWAY-GOLDEN (a pristine-right -> patched-wrong REGRESSION),
STILL-WRONG (wrong before and after) or STILL-RIGHT.  Multiset-keyed.
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        t = ln.split()
        if not t or t[0] != 'PA':
            continue
        d[(t[1], t[2], t[4])].append(' '.join(t[5:]))
    return d

def main():
    g, b, a = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
    tag = sys.argv[4] if len(sys.argv) > 4 else ''
    cnt = collections.Counter()
    rows = []
    for k in sorted(set(g) | set(b) | set(a)):
        gv, bv, av = g.get(k, []), b.get(k, []), a.get(k, [])
        n = max(len(gv), len(bv), len(av))
        for i in range(n):
            G = gv[i] if i < len(gv) else '<absent>'
            B = bv[i] if i < len(bv) else '<absent>'
            A = av[i] if i < len(av) else '<absent>'
            if B == A:
                v = 'STILL-RIGHT' if G == A else 'STILL-WRONG'
            elif A == G:
                v = 'TO-GOLDEN'
            elif B == G:
                v = 'AWAY-GOLDEN'
            else:
                v = 'MOVED-WRONG'
            cnt[v] += 1
            if v not in ('STILL-RIGHT',):
                rows.append('%-12s %s %s %s\n     G %s\n     B %s\n     A %s' %
                            (v, k[0], k[1], k[2], G, B, A))
    print('== %s ==' % tag)
    for r in rows:
        print(r)
    print('%s TOTALS %s' % (tag, dict(cnt)))

main()
