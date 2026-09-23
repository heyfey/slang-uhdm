#!/usr/bin/env python3
"""r11u104 NAME-keyed cell scorer — nda97.py's per-field TO/AWAY/MOVED-WRONG
over nda104.read (every cont_assign at any depth, keyed on the LHS name +
occurrence, the written-assign views apart), with the FIVE fields loc97v
reads (value PREFIX, value DIGITS, const type, size, decompile).
usage: score104.py <golden.dump> <A.dump> <B.dump>   (A=before, B=after;
       swap A and B for the positive control: every TO becomes an AWAY)"""
import sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from nda104 import read

FIELDS = ('vp', 'vd', 'ct', 'sz', 'd')

def split(c):
    if c.get('kind') != 'constant': return c
    c = dict(c)
    p, _, d = c['v'].partition(':')
    c['vp'], c['vd'] = p, d
    return c

g, a, b = ({k: split(v) for k, v in read(x).items()} for x in sys.argv[1:4])
tot = dict(TO=0, AWAY=0, STILL=0, EQ=0, MWRONG=0, MISSING=0, NOFOLD=0, SHAPE=0,
           NFMOVE=0, NOGMOVE=0)
for n in sorted(g):
    G, A, B = g[n], a.get(n), b.get(n)
    if A is None or B is None:
        tot['MISSING'] += 1; print(f'{n:14s} MISSING on one side'); continue
    if G['kind'] != 'constant':
        tot['NOFOLD'] += 1
        if A['kind'] != B['kind']:
            tot['SHAPE'] += 1
            print(f'{n:14s} NOFOLD golden={G["kind"]} A={A["kind"]} B={B["kind"]} *** SHAPE MOVED ***')
        elif A != B:
            # golden writes no constant: unscoreable, but a move is REPORTED
            tot['NFMOVE'] += 1
            print(f'{n:14s} NOFOLD-MOVE golden={G["kind"]} A={A.get("v")} sz{A.get("sz")} B={B.get("v")} sz{B.get("sz")}')
        continue
    if A['kind'] != 'constant' or B['kind'] != 'constant':
        if A['kind'] != B['kind']:
            tot['SHAPE'] += 1
            print(f'{n:14s} SHAPE golden=constant A={A["kind"]} B={B["kind"]}')
        continue
    marks = []
    for f in FIELDS:
        if A[f] == G[f] and B[f] == G[f]: tot['EQ'] += 1
        elif A[f] != G[f] and B[f] == G[f]: tot['TO'] += 1; marks.append('TO:' + f)
        elif A[f] == G[f] and B[f] != G[f]:
            tot['AWAY'] += 1; tot['MWRONG'] += 1; marks.append('AWAY:' + f)
        elif A[f] == B[f]: tot['STILL'] += 1
        else: tot['STILL'] += 1; tot['MWRONG'] += 1; marks.append('MOVED-WRONG:' + f)
    if marks:
        print(f'{n:14s} g[{G["v"]} ct{G["ct"]} sz{G["sz"]} d{G["d"]}] '
              f'A[{A["v"]} ct{A["ct"]} sz{A["sz"]} d{A["d"]}] '
              f'B[{B["v"]} ct{B["ct"]} sz{B["sz"]} d{B["d"]}] ' + ' '.join(marks))
for n in sorted(set(a) | set(b)):
    if n in g:
        continue
    if a.get(n) != b.get(n):
        # a cell golden does not write at all (GOLDEN WRITES NOTHING): reported
        tot['NOGMOVE'] += 1
        print(f'{n:14s} NO-GOLDEN-CELL-MOVE A={a.get(n)} B={b.get(n)}')
print('  '.join(f'{k}={v}' for k, v in tot.items()))
