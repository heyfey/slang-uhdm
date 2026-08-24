#!/usr/bin/env python3
"""r10uvm121 — GRID SCORER for the purpose-built goldens.

  score121.py <golden.dump> <pristine.dump> <patched.dump> [<source.sv>]

Cell key   = (view, span)      — the arm's own stable name (Compare reads no
                                 span; the arms are single files with one
                                 assignment per line, so the span IS the cell)
Cell value = MULTISET of (Rhs-kind, Lhs-kind), '<absent>' when the slot holds
             no assignment at all — so a pass that REMOVES objects is scored on
             ONE-SIDED sets, never inside a "DIFF" (uvm109's lesson).

Verdicts per cell, golden as truth:
  ALREADY-RIGHT  pristine == golden and patched == golden
  TO-GOLDEN      pristine != golden and patched == golden
  AWAY-GOLDEN    pristine == golden and patched != golden      <- must be 0
  STILL-WRONG    pristine != golden and patched != golden (unchanged)
  CHANGED-STILL-WRONG  pristine != golden, patched != golden, and different

MEASUREMENT ONLY; the official uhdm-cmp is the judge.
"""
import sys, collections
import armcen121

def cells(path):
    d = collections.defaultdict(collections.Counter)
    for view, span, val in armcen121.parse(path):
        d[(view, span)][val] += 1
    return d

def main(gp, pp, xp, src=None):
    g, p, x = cells(gp), cells(pp), cells(xp)
    lines = open(src).read().split('\n') if src else []
    keys = sorted(set(g) | set(p) | set(x), key=lambda k: (int(k[1].split(':')[0]), k[0]))
    tot = collections.Counter()
    print('%-13s %-14s %-9s | %s' % ('VIEW', 'SPAN', 'VERDICT', 'SOURCE'))
    for k in keys:
        gv, pv, xv = g.get(k, collections.Counter()), p.get(k, collections.Counter()), x.get(k, collections.Counter())
        if pv == gv and xv == gv: v = 'ALREADY-RIGHT'
        elif pv != gv and xv == gv: v = 'TO-GOLDEN'
        elif pv == gv and xv != gv: v = 'AWAY-GOLDEN'
        elif pv == xv: v = 'STILL-WRONG'
        else: v = 'CHANGED-STILL-WRONG'
        tot[v] += 1
        ln = int(k[1].split(':')[0])
        txt = lines[ln-1].strip()[:58] if 0 < ln <= len(lines) else ''
        print('%-13s %-14s %-9s | %s' % (k[0], k[1], v, txt))
        if v != 'ALREADY-RIGHT':
            print('%29s G=%s' % ('', dict(gv) or '<absent>'))
            print('%29s P=%s' % ('', dict(pv) or '<absent>'))
            print('%29s X=%s' % ('', dict(xv) or '<absent>'))
    print('-- ' + '  '.join('%s=%d' % (k, tot[k]) for k in
          ('ALREADY-RIGHT','TO-GOLDEN','AWAY-GOLDEN','STILL-WRONG','CHANGED-STILL-WRONG')))

if __name__ == '__main__':
    main(*sys.argv[1:])
