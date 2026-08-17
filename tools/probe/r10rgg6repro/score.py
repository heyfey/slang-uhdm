#!/usr/bin/env python3
"""r10rgg6/score.py -- one row per grid cell: what GOLDEN does with the
param-initializer call `P1 = f1(N)` in each view, and what OURS does.

Columns
  cell        the cell directory name (topo_third_nN_fold_formal_site[_2ts])
  ndef/nelab  how many P1 func_calls the view holds (instances)
  gDEF        golden's DEF-view P1 call: '-' no ts, or the ts actual
  gELAB       golden's ELAB-view P1 calls: '-' none stamped, 'k/n@actual'
  oELAB       ours, same key
  V           MATCH / DIFF  (golden vs ours on the ELAB P1 stamp)
"""
import os, sys, collections

OUT = sys.argv[1]

def load(p):
    rows = []
    if not os.path.exists(p):
        return rows
    for line in open(p):
        f = line.rstrip('\n').split('\t')
        if len(f) >= 8:
            rows.append(f)
    return rows

def summarise(rows, view, lhs):
    sel = [r for r in rows if r[0] == view and r[2] == lhs]
    if not sel:
        return '(absent)', 0
    stamped = [r for r in sel if r[5] == 'ts']
    if not stamped:
        return '-', len(sel)
    acts = sorted(set(r[6] for r in stamped))
    return '%d/%d@%s' % (len(stamped), len(sel), ','.join(acts)), len(sel)

print('%-42s %5s %5s %-22s %-26s %-26s %s' %
      ('cell', 'nDEF', 'nELB', 'gDEF(P1)', 'gELAB(P1)', 'oELAB(P1)', 'V'))
nm = nd = 0
for c in sorted(os.listdir(OUT)):
    d = os.path.join(OUT, c)
    if not os.path.isdir(d):
        continue
    g = load(os.path.join(d, 'gold.calls.tsv'))
    o = load(os.path.join(d, 'ours.calls.tsv'))
    if not g:
        print('%-42s %s' % (c, 'NODB/NOGOLD'))
        continue
    gd, nde = summarise(g, 'DEF', 'P1')
    ge, nel = summarise(g, 'ELAB', 'P1')
    oe, _   = summarise(o, 'ELAB', 'P1') if o else ('(noslang)', 0)
    v = 'MATCH' if ge == oe else 'DIFF'
    if o:
        nm += (v == 'MATCH'); nd += (v == 'DIFF')
    else:
        v = 'NOSLANG'
    print('%-42s %5d %5d %-22s %-26s %-26s %s' % (c, nde, nel, gd, ge, oe, v))
print('-- MATCH=%d DIFF=%d' % (nm, nd))
