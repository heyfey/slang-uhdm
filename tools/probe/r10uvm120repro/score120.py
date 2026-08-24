#!/usr/bin/env python3
"""r10uvm120 — score one arm directory: per (view, subroutine, return) cell,
TOGOLD / MOVEDWRONG / STILLDIFF / MOVED-OTHER between g.ret, pris.ret, pat.ret.
MEASUREMENT ONLY; the official uhdm-cmp is the judge.
    score120.py <armdir> [--quiet]
"""
import sys, os


def blocks(f):
    d, k = {}, None
    if not os.path.exists(f):
        return d
    for l in open(f).read().strip().split('\n'):
        if not l:
            continue
        if not l.startswith(' '):
            k = l
            d[k] = []
        else:
            d[k].append(l.strip())
    return d


def main(argv):
    d = argv[1]
    quiet = '--quiet' in argv
    G, P, Q = (blocks(os.path.join(d, x)) for x in ('g.ret', 'pris.ret',
                                                    'pat.ret'))
    tally = {}
    for k in sorted(set(G) | set(P) | set(Q)):
        g, p, q = G.get(k), P.get(k), Q.get(k)
        if p == q:
            st = 'SAME' if g == q else 'STILLDIFF'
        elif q == g:
            st = 'TOGOLD'
        elif p == g:
            st = 'MOVEDWRONG'
        else:
            st = 'MOVED-OTHER'
        tally[st] = tally.get(st, 0) + 1
        if st in ('MOVEDWRONG', 'MOVED-OTHER') or (not quiet and st != 'SAME'):
            print(st, k)
            if st != 'TOGOLD':
                print('   G:', g)
                print('   P:', p)
                print('   Q:', q)
    print(os.path.basename(d.rstrip('/')), ' '.join(
        '%s=%d' % (k, tally[k]) for k in sorted(tally)))


main(sys.argv)
