#!/usr/bin/env python3
"""r10v133 (VERIFIER) — EXACT-MULTISET query-call census/join.

Difference from the implementer's qjoin133.py, on purpose: a SITE's verdict is
computed from the EXACT PAIR (number of KEPT copies, number of FOLDED copies)
on each side, not from "does either side have at least one KEPT".  A site where
golden keeps ONE copy and folds ANOTHER (a param_assign that appears in both
the definition listing and the elaborated copy) is therefore scored honestly:
matching only one of the two copies is NOT a match.

usage: v133cen.py <g.dump> <pris.dump> <pat.dump> [tag]
"""
import sys, collections, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qcen133


def state(path):
    d = collections.defaultdict(lambda: [0, 0])
    kinds = {}
    for start, nm, st, ak, an in qcen133.cells(path):
        if st == 'KEPT':
            d[start][0] += 1
            kinds[start] = (nm, ak, an)
        else:
            d[start][1] += 1
    return d, kinds


def main():
    g, gk = state(sys.argv[1])
    p, pk = state(sys.argv[2])
    q, qk = state(sys.argv[3])
    tag = sys.argv[4] if len(sys.argv) > 4 else ''
    tot = collections.Counter()
    for k in sorted(set(g) | set(p) | set(q), key=lambda s: tuple(int(x) for x in s.split(':'))):
        G, P, Q = tuple(g.get(k, [0, 0])), tuple(p.get(k, [0, 0])), tuple(q.get(k, [0, 0]))
        # a site nobody kept a query call at on any side is not a cell
        if G[0] == 0 and P[0] == 0 and Q[0] == 0:
            continue
        info = gk.get(k) or pk.get(k) or qk.get(k) or ('-', '-', '')
        if P == G and Q == G:
            tot['SAME-RIGHT'] += 1
            continue
        if P != G and Q == G:
            v = 'TOGOLD'
        elif P == G and Q != G:
            v = 'MOVED-WRONG'
        elif P != Q:
            v = 'MOVED-OTHER'
        else:
            v = 'STILL-WRONG'
        tot[v] += 1
        if v != 'STILL-WRONG':
            print(f'{tag}\t{k}\t{v}\t{info[0]}\t{info[1]}\t{info[2]}\tG(keep,fold)={G} P={P} Q={Q}')
    print(f'{tag}\tTOTALS\t' + ' '.join(f'{a}={b}' for a, b in sorted(tot.items())))


main()
