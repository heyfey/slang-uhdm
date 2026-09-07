#!/usr/bin/env python3
"""r10earl119 -- PREDICT the mover set BY NAME from the PRISTINE databases
BEFORE the patched sweep exists.

    predict119.py <pristine-census.tsv>

`applyCaCastFoldDef119` can only touch a cell that is ALL of:
  * homed in a `gen_scope` and reached from the design's TOP MODULES,
  * whose `cont_assign::Lhs` is a plain `ref_obj`,
  * whose Rhs is still an `operation` of type `vpiCastOp` (67),
  * with EXACTLY ONE operand, and that operand already a `constant`,
  * under a cast typespec `ExprEval`'s `vpiCastOp` arm has a branch for
    (int / long_int / bit / short_int / integer / enum),
  * in a run where `--elabuhdm` was NOT given (in the other view
    `applyCaCastAdjust106` runs instead and this function is never called).

cen119's LOCCELL line carries the Rhs payload, the operand kind and the cast
typespec kind, all read off the DATABASE, so that set is computable from the
pristine sweep alone.  The `--elabuhdm` half is NOT visible in a census, so
this predictor prints BOTH modes and the caller crosses them with the workdir's
own cmds.txt (an `--elabuhdm` row cannot move, by construction).

Prints, per side:
  PREDICT-MOVE <mode> <test> <cells>   OURS holds such a cell AND golden holds
                                       a FOLDED CONSTANT on the same key
                                       (a TO-GOLDEN move)
  PREDICT-AWAY <mode> <test>           OURS holds such a cell and golden does
                                       NOT hold a constant there -- the law
                                       would move it AWAY; must be empty
  PREDICT-DECLINE                      cells golden folds that this law leaves
                                       alone (the R1 residue), for the record
"""
import sys
from collections import defaultdict

FOLDABLE_TS = {'int_typespec', 'long_int_typespec', 'bit_typespec',
               'short_int_typespec', 'integer_typespec', 'enum_typespec'}


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    reach = defaultdict(int)        # (mode,test) -> reachable cells (ours)
    reachkeys = defaultdict(set)
    decline = defaultdict(int)      # golden folds, we cannot reach
    gold = defaultdict(dict)        # (mode,test,key) -> golden payload set
    with open(sys.argv[1]) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 9 or p[3] != 'LOCCELL':
                continue
            side, mode, test, cnt, key, pay, loc, diag = (
                p[0], p[1], p[2], int(p[4]), p[5], p[6], p[7], p[8])
            parts = key.split('|')
            if len(parts) < 4 or parts[1] != 'gen_scope' or parts[3] != 'ref_obj':
                continue
            if side == 'G':
                if pay.startswith('const|'):
                    gold[(mode, test)][key] = pay
                continue
            if not pay.startswith('op67'):
                continue
            d = diag.split('/')
            if len(d) < 2 or d[0] != 'constant' or d[1] not in FOLDABLE_TS:
                decline[(mode, test)] += cnt
                continue
            if len(d) > 2:          # more than one operand
                decline[(mode, test)] += cnt
                continue
            reach[(mode, test)] += cnt
            reachkeys[(mode, test)].add(key)

    print('-- PREDICTED MOVERS (reachable cell + golden holds a folded constant) --')
    rows = 0
    cells = 0
    away = []
    for k in sorted(reach):
        g = gold.get(k, {})
        hit = [x for x in reachkeys[k] if x in g]
        miss = [x for x in reachkeys[k] if x not in g]
        if hit:
            rows += 1
            cells += len(hit)
            print('PREDICT-MOVE %-9s %-30s %d cells' % (k[0], k[1], len(hit)))
        if miss:
            away.append((k, miss))
    print('  rows=%d  cells=%d' % (rows, cells))
    print('-- PREDICT-AWAY (reachable but golden does NOT fold: must be empty) --')
    for k, miss in away:
        print('PREDICT-AWAY %-9s %-30s %d cells' % (k[0], k[1], len(miss)))
        for m in sorted(miss)[:4]:
            print('      %s' % m)
    print('  rows=%d' % len(away))
    print('-- PREDICT-DECLINE (op67 cells this law does not reach: the R1 residue) --')
    tot = 0
    for k in sorted(decline):
        tot += decline[k]
    print('  rows=%d  cells=%d' % (len(decline), tot))
    return 0


if __name__ == '__main__':
    sys.exit(main())
