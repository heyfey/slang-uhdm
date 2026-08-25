#!/usr/bin/env python3
"""r10earl89 — the FIELD-WISE scorer for the ONE field this law owns.

`score89.py` scores the WHOLE cell, which reports a cell whose typespec moved
TO golden while a PRE-EXISTING size residue stays wrong as WRONG->OTHER.  This
scorer isolates the `Typespec` leg-by-leg, so the law's own answer is judged on
its own, and asserts that NO OTHER FIELD moved (earl63/earl65: score
field-by-field).  MEASUREMENT ONLY.

  usage: tsscore89.py <golden.rg> <pristine.rg> <patched.rg>
"""
import re, sys, collections

LEG = re.compile(r'(\S+)\{ct=(-?\d+) sz=(-?\d+) val=(\S+) dec=(\S+) (TS=[^}]*)\}')

def load(p):
    d = collections.defaultdict(set)
    for ln in open(p):
        ln = ln.split(' || SPANS:')[0].rstrip()
        m = re.match(r'RG (.*)\|(#\d+) (.*)$', ln)
        if m:
            d[(m.group(1), m.group(2))].add(m.group(3))
    return d

def legs(pays):
    """one dict path->(non-ts fields, ts) per DEDUPED payload, merged."""
    out = {}
    for p in sorted(pays):
        for path, ct, sz, val, dec, ts in LEG.findall(p):
            out.setdefault(path, set()).add(((ct, sz, val, dec), ts))
    return out

def main():
    G, O, Q = (load(a) for a in sys.argv[1:4])
    b = collections.Counter()
    rows = []
    for k in sorted(set(G) & set(O) & set(Q)):
        lg, lo, lq = legs(G[k]), legs(O[k]), legs(Q[k])
        for path in sorted(set(lo) | set(lq)):
            o, q = lo.get(path), lq.get(path)
            if o == q:
                continue
            b['OTHER-FIELD-MOVED'] += len({x[0] for x in o or ()} ^
                                          {x[0] for x in q or ()}) and 1 or 0
            g = lg.get(path)
            gt = {t for _, t in g} if g else None
            ot = {t for _, t in o} if o else None
            qt = {t for _, t in q} if q else None
            if gt is None:
                b['TS-NO-GOLDEN-LEG'] += 1; rows.append(('TS-NO-GOLDEN-LEG', k, path, gt, ot, qt)); continue
            if qt == gt and ot != gt:
                b['TS-WRONG->RIGHT'] += 1
            elif ot == gt and qt != gt:
                b['TS-RIGHT->WRONG'] += 1; rows.append(('TS-RIGHT->WRONG', k, path, gt, ot, qt))
            else:
                b['TS-WRONG->OTHER'] += 1; rows.append(('TS-WRONG->OTHER', k, path, gt, ot, qt))
    # unmoved legs, for the denominator
    for k in sorted(set(G) & set(O) & set(Q)):
        lg, lo, lq = legs(G[k]), legs(O[k]), legs(Q[k])
        for path in sorted(set(lo) & set(lq)):
            if lo[path] != lq[path]:
                continue
            g = lg.get(path)
            if g is None:
                continue
            b['TS-SAME-RIGHT' if {t for _, t in g} == {t for _, t in lo[path]}
              else 'TS-SAME-WRONG'] += 1
    for n in ('TS-SAME-RIGHT', 'TS-SAME-WRONG', 'TS-WRONG->RIGHT',
              'TS-RIGHT->WRONG', 'TS-WRONG->OTHER', 'TS-NO-GOLDEN-LEG',
              'OTHER-FIELD-MOVED'):
        print(f'{n:<20} {b[n]}')
    for r in rows:
        print(f'\n[{r[0]}] {r[1][0]} {r[1][1]} leg {r[2]}\n'
              f'  G:{r[3]}  O:{r[4]}  Q:{r[5]}')

main()
