#!/usr/bin/env python3
"""compose.py <wd_alloff> <wd_147off> <wd_152off> <wd_on>: the composition census of the two landings.
Per row / probe case, v = (status, strict) under A = both landings off, X = pass 147's landing off (152 alone),
Y = pass 152's landing off (147 alone), L = both on.  Classes:
  ONLY147   Y != A, X == A, L == Y       ONLY152   X != A, Y == A, L == X
  JOINT     L != A, X == A, Y == A       (a move only the two landings together make)
  CANCEL    L == A, X != A, Y != A       (each alone moves, together they cancel)
  BOTH      X != A, Y != A, L != A       (both move it; L named)
  NONADD    anything else (L differs from what the one moving landing gives)
Fenced rows print as FENCED_n (their verdicts are sweep verdicts; no database is read)."""
import csv, sys, os, collections
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('compose.py: source drivers/env.sh first')
A, X, Y, L = sys.argv[1:5]
def load(wd, st):
    p = f'{wd}/{st}.csv'
    if st == 'probe': return {r['case']: (r['status'], r['strict']) for r in csv.DictReader(open(p))}
    return {(r['name'], r['mode']): (r['status'], r['strict']) for r in csv.DictReader(open(p))}
def nm(k):
    if isinstance(k, tuple):
        n = f'FENCED_{FENCED.index(k[0])+1}' if k[0] in FENCED else k[0]
        return f'{n},{k[1]}'
    return k
def fmt(v): return 'CMP_EQUAL' if v[0] == 'CMP_EQUAL' else f'{v[0]}:{v[1]}'
for st in ('probe', 'surelog', 'uhdm2rtlil'):
    a, x, y, l = (load(w, st) for w in (A, X, Y, L))
    c = collections.Counter(); lines = []
    for k in sorted(set(a) | set(l), key=str):
        va, vx, vy, vl = a.get(k), x.get(k), y.get(k), l.get(k)
        if va == vx == vy == vl: continue
        if vy != va and vx == va and vl == vy: cl = 'ONLY147'
        elif vx != va and vy == va and vl == vx: cl = 'ONLY152'
        elif vl != va and vx == va and vy == va: cl = 'JOINT'
        elif vl == va and vx != va and vy != va: cl = 'CANCEL'
        elif vx != va and vy != va: cl = 'BOTH'
        else: cl = 'NONADD'
        conv = 'conv' if vl and vl[0] == 'CMP_EQUAL' and va[0] != 'CMP_EQUAL' else 'chg'
        c[(cl, conv)] += 1
        lines.append(f'{cl:8s} {conv} {nm(k)} | A {fmt(va)} | X(152 alone) {fmt(vx)} | Y(147 alone) {fmt(vy)} | L {fmt(vl)}')
    print(f'== {st}: ' + ' '.join(f'{k[0]}/{k[1]}={v}' for k, v in sorted(c.items())))
    for ln in lines: print('  ' + ln)
