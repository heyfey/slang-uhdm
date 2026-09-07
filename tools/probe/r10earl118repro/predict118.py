#!/usr/bin/env python3
"""r10earl118 -- PREDICT the mover set BY NAME from the PRISTINE databases
BEFORE the patched sweep exists.

    predict118.py <pristine-census.tsv>

The law § genCaCastRhsOwnLocalLhsNoBind118 changes exactly one thing: a
generate-scope `cont_assign` whose Rhs is a CAST (`vpiCastOp`, op type 67) and
whose whole-name target is a variable declared in THAT SAME generate scope
loses its `Actual_group`.  cen118's RCELL line carries all three columns
(scope kind, Rhs shape, declaration home), read off the DATABASE, so the set of
rows the patch can possibly move is computable from the pristine sweep alone.

Prints, per side:
  PREDICT-MOVE <mode> <test> <cells>     rows whose OURS database holds at
                                         least one such cell that is BOUND
  PREDICT-GOLD <mode> <test> <cells>     the same cells on the GOLDEN side,
                                         with golden's own payload -- if golden
                                         is `<null>` there the move is
                                         TO-GOLDEN, if it is bound the move
                                         would be AWAY and the law is wrong.
"""
import sys
from collections import defaultdict


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    ours = defaultdict(int)
    oursnull = defaultdict(int)
    gold = defaultdict(lambda: defaultdict(int))
    with open(sys.argv[1]) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 8 or p[3] != 'RCELL':
                continue
            side, mode, test, _t, cnt, key, rhs, home, pay = (
                p[0], p[1], p[2], p[3], int(p[4]), p[5], p[6], p[7], p[8])
            parts = key.split('|')
            if len(parts) < 4:
                continue
            if parts[1] != 'gen_scope' or parts[3] != 'ref_obj':
                continue
            if rhs != 'op67' or home != 'own':
                continue
            if side == 'O':
                if pay == '<null>':
                    oursnull[(mode, test)] += cnt
                else:
                    ours[(mode, test)] += cnt
            else:
                gold[(mode, test)][pay] += cnt

    print('-- PREDICTED MOVERS (ours BOUND on an op67/own gen-scope target) --')
    for k in sorted(ours):
        print('PREDICT-MOVE %-9s %-28s %d cells' % (k[0], k[1], ours[k]))
    print('  rows=%d  cells=%d' % (len(ours), sum(ours.values())))
    print('-- GOLDEN on the SAME cells (must be <null> for a TO-GOLDEN move) --')
    bad = 0
    for k in sorted(ours):
        g = dict(gold.get(k, {}))
        flag = ''
        if any(p != '<null>' for p in g):
            flag = '   <== GOLDEN BINDS SOME: would be AWAY'
            bad += 1
        print('PREDICT-GOLD %-9s %-28s %s%s' % (k[0], k[1], g, flag))
    print('  rows where golden binds some such cell: %d (must be 0)' % bad)
    print('-- rows where OURS is ALREADY <null> on such a cell (no move) --')
    for k in sorted(oursnull):
        if k not in ours:
            print('PREDICT-NOMOVE %-9s %-28s %d cells' % (k[0], k[1], oursnull[k]))
    return 0


if __name__ == '__main__':
    sys.exit(main())
