#!/usr/bin/env python3
"""r11u40 — the THREE-WAY cell score (gold x pristine x law), on TWO axes.

    score35.py <gold.census> <pris.census> <law.census> [--list]

Each cell is (view, holder-chain, range loc, side), as `rangecensus35.py`
prints it.  Two axes, both reported, because they answer different questions
and this pass moves exactly one of them:

  SHAPE-SET   the SET of distinct bound shapes+encodings at the cell.  THIS is
              the fold-decision axis: "does golden keep the written operation
              here and do we".  It is the axis § typeParamAnonAggMemberNoReduce35
              moves.
  MULTISET    the same with MULTIPLICITIES.  Our typespec POOL carries a
              different number of copies of one declaration's typespec than
              Surelog's does — a residue that PREDATES this pass and that no
              fold decision can close — so a multiset score reads almost every
              cell as unequal both before and after.  It is printed so the
              copy-count residue is visible and never silently folded into the
              law's own score.

Buckets per axis: TO-GOLDEN (was unequal, now equal) / AWAY-GOLDEN (was equal,
now unequal) / MOVED-WRONG (unequal before and after, and CHANGED) /
STILL-WRONG (unequal, unchanged) / UNMOVED (equal, unchanged).  A cell present
on one side only is its own bucket and is counted: a census that reaches
nothing must never read as perfection.
"""
import sys
from collections import Counter


def read(p):
    out = {}
    for ln in open(p):
        if ln.startswith('--'):
            continue
        f = ln.rstrip('\n').split(None, 4)
        if len(f) < 5:
            continue
        view, chain, loc, side, rest = f
        parts = rest.rsplit(None, 2)
        enc = parts[0].strip() if len(parts) == 3 else rest.strip()
        mult = int(parts[2][1:]) if len(parts) == 3 else 0
        out.setdefault((view, chain, loc, side), Counter())[enc] += mult
    return out


def score(g, a, b, axis, show):
    keys = sorted(set(g) | set(a) | set(b))
    c = Counter()
    for k in keys:
        gv, av, bv = g.get(k), a.get(k), b.get(k)

        def norm(v):
            if v is None:
                return None
            return frozenset(v) if axis == 'set' else tuple(sorted(v.items()))
        gn, an, bn = norm(gv), norm(av), norm(bv)
        was, now = (an == gn), (bn == gn)
        if was and now:
            c['UNMOVED'] += 1
        elif not was and now:
            c['TO-GOLDEN'] += 1
            if show:
                print('TO-GOLDEN    %s %s %s  %s -> %s' % (k[0][:30], k[2], k[3],
                                                           sorted(av or []),
                                                           sorted(bv or [])))
        elif was and not now:
            c['AWAY-GOLDEN'] += 1
            print('AWAY-GOLDEN  %s %s %s  %s -> %s' % (k[0][:30], k[2], k[3],
                                                       sorted(av or []),
                                                       sorted(bv or [])))
        elif an != bn:
            c['MOVED-WRONG'] += 1
            if show:
                print('MOVED-WRONG  %s %s %s  gold %s | %s -> %s'
                      % (k[0][:30], k[2], k[3], sorted(gv or []),
                         sorted(av or []), sorted(bv or [])))
        else:
            c['STILL-WRONG'] += 1
    print('[%s] TO-GOLDEN=%d AWAY-GOLDEN=%d MOVED-WRONG=%d STILL-WRONG=%d '
          'UNMOVED=%d' % (axis.upper(), c['TO-GOLDEN'], c['AWAY-GOLDEN'],
                          c['MOVED-WRONG'], c['STILL-WRONG'], c['UNMOVED']))
    return c


def main():
    show = '--list' in sys.argv
    args = [a for a in sys.argv[1:] if a != '--list']
    g, a, b = read(args[0]), read(args[1]), read(args[2])
    score(g, a, b, 'set', show)
    score(g, a, b, 'multiset', show)


if __name__ == '__main__':
    main()
