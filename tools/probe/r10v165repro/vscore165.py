#!/usr/bin/env python3
"""r10v165repro/vscore165.py — the VERIFIER's cell scorer.  MEASUREMENT ONLY.

  vscore165.py <g.arg> <a.arg(pristine)> <b.arg(patched)> <label>

Joins the three argument censuses as MULTISETS on the cell IDENTITY
(kind|name|span|call), so a body that an elaborated package holds twice is not
collapsed by a dict.  For every identity it prints the golden / pristine /
patched BOUND-BARE multiset and the verdict:

  TOWARD        pristine disagreed with golden, patched agrees
  AWAY          pristine agreed with golden, patched does not   <-- A REGRESSION
  STILL-WRONG   both disagree, unchanged
  SIDEWAYS      both disagree, differently (distance printed)
  OK            both agree
"""
import sys
from collections import Counter, defaultdict


def load(p):
    d = defaultdict(Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln:
            continue
        f = ln.split('|')
        # ARG kind name span call bound xN
        ident = '|'.join(f[0:5])
        val = f[5]
        n = int(f[6][1:])
        d[ident][val] += n
    return d


def dist(a, b):
    keys = set(a) | set(b)
    return sum(abs(a.get(k, 0) - b.get(k, 0)) for k in keys)


def main():
    g, a, b, label = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3]), sys.argv[4]
    idents = sorted(set(g) | set(a) | set(b))
    n = Counter()
    for i in idents:
        G, A, B = g.get(i, Counter()), a.get(i, Counter()), b.get(i, Counter())
        da, db = dist(G, A), dist(G, B)
        if da == 0 and db == 0:
            v = 'OK'
        elif da > 0 and db == 0:
            v = 'TOWARD'
        elif da == 0 and db > 0:
            v = 'AWAY'
        elif A == B:
            v = 'STILL-WRONG'
        else:
            v = 'SIDEWAYS'
        n[v] += 1
        if v != 'OK':
            print('%s %-12s %s  G=%s pris=%s pat=%s  dist pris=%d pat=%d'
                  % (label, v, i, dict(G), dict(A), dict(B), da, db))
    print('%s SUMMARY %s  total_idents=%d  DIST pris=%d pat=%d'
          % (label, dict(n), len(idents),
             sum(dist(g.get(i, Counter()), a.get(i, Counter())) for i in idents),
             sum(dist(g.get(i, Counter()), b.get(i, Counter())) for i in idents)))


if __name__ == '__main__':
    main()
