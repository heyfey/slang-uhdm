#!/usr/bin/env python3
"""r10earl89 — the 3-way scorer for one arm.

Keys on the CELL IDENTITY (owner chain + owner kind + range ordinal) and
carries ONLY judge-visible fields in the payload — NO SPAN (earl60/earl69: a
span-carrying payload hides a flip).  Payloads are DEDUPED per key because our
databases list a definition cell and an elaborated cell under one owner name
(earl88's score88.py lesson).  MEASUREMENT ONLY.

  usage: score89.py <golden.rg> <pristine.rg> [<patched.rg>] [--full]
"""
import re, sys, collections

def load(p):
    d = collections.defaultdict(set)
    for ln in open(p):
        ln = ln.split(' || SPANS:')[0].rstrip()
        m = re.match(r'RG (.*)\|(#\d+) (.*)$', ln)
        if not m:
            continue
        key, ordn, pay = m.groups()
        d[(key, ordn)].add(pay)
    return d

def one(s):
    return ' ;; '.join(sorted(s)) if s else '<absent>'

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    full = '--full' in sys.argv
    G = load(args[0]); O = load(args[1])
    Q = load(args[2]) if len(args) > 2 else None
    keys = sorted(set(G) | set(O) | (set(Q) if Q else set()))
    b = collections.Counter()
    rows = []
    for k in keys:
        g, o = one(G.get(k, set())), one(O.get(k, set()))
        q = one(Q.get(k, set())) if Q else o
        if k not in G:
            b['ONLY-OURS'] += 1; continue
        if k not in O and (not Q or k not in Q):
            b['ONLY-GOLDEN'] += 1; continue
        if o == q:
            b['SAME-RIGHT' if o == g else 'SAME-WRONG'] += 1
            if o != g and full:
                rows.append(('STILL-WRONG', k, g, o, q))
            continue
        if q == g:
            b['WRONG->RIGHT'] += 1; rows.append(('WRONG->RIGHT', k, g, o, q))
        elif o == g:
            b['RIGHT->WRONG'] += 1; rows.append(('RIGHT->WRONG', k, g, o, q))
        else:
            b['WRONG->OTHER'] += 1; rows.append(('WRONG->OTHER', k, g, o, q))
    for n in ('SAME-RIGHT', 'SAME-WRONG', 'WRONG->RIGHT', 'RIGHT->WRONG',
              'WRONG->OTHER', 'ONLY-GOLDEN', 'ONLY-OURS'):
        print(f'{n:<14} {b[n]}')
    for r in rows:
        print(f'\n[{r[0]}] {r[1][0]} {r[1][1]}\n  G: {r[2]}\n  O: {r[3]}\n  Q: {r[4]}')

main()
