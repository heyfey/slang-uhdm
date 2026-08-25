#!/usr/bin/env python3
"""r10earl92 — print ONE LINE PER CONT_ASSIGN CELL for a grid arm, three ways.

Reads g.rows (golden Surelog), o.rows (pristine) and q.rows (patched) written
by arm92.sh and prints, per (LSPAN, LNAME, VIEW, INST) key, the Rhs FINGERPRINT
each side produced.  A cell where golden and pristine agree is a CONTROL and is
printed too: an arm AGREEING with golden is not an arm TESTING the law, so the
whole denominator is on the page (earl66's rule).

usage: cells92.py <armdir> [--all]
"""
import sys, os, collections

def load(p):
    rows = collections.defaultdict(list)
    if not os.path.exists(p): return rows
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln.startswith('CA\t'): continue
        k, _, pay = ln.partition('\t||\t')
        f = dict(x.split('=', 1) for x in k.split('\t')[1:])
        pay, _, diag = pay.partition('\tDIAG\t')
        g = dict(x.split('=', 1) for x in pay.split('\t'))
        g.update(dict(x.split('=', 1) for x in diag.split('\t')) if diag else {})
        key = (f['LSPAN'], f['LNAME'], f['VIEW'], f['INST'])
        rows[key].append('%s:%s@%s %s' % (g['RK'], g['ROP'], g.get('RSPAN', '-'), g['ROPK']))
    for v in rows.values(): v.sort()
    return rows

d = sys.argv[1]
showall = '--all' in sys.argv
G, O, Q = (load(os.path.join(d, f)) for f in ('g.rows', 'o.rows', 'q.rows'))
keys = sorted(set(G) | set(O) | set(Q), key=lambda k: (k[2], int(k[0].split(':')[0]) if k[0][0].isdigit() else 0, k[1]))
w = max([len(k[1]) for k in keys] + [4])
print('%-6s %-9s %-*s  %-34s %-34s %s' % ('VIEW', 'LSPAN', w, 'LNAME', 'GOLDEN', 'PRISTINE', 'PATCHED'))
for k in keys:
    g, o, q = G.get(k, []), O.get(k, []), Q.get(k, [])
    verdict = '' if g == o == q else ('  <== ' + ('FIXED' if g == q and g != o else
                                                 'BROKE' if g == o and g != q else 'DIFF'))
    if not showall and g == o == q: continue
    print('%-6s %-9s %-*s  %-34s %-34s %s%s' % (k[2], k[0], w, k[1],
          ';'.join(g) or '-', ';'.join(o) or '-', ';'.join(q) or '-', verdict))
