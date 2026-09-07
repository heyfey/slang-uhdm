#!/usr/bin/env python3
"""r10earl113 -- THE MOVER PREDICTION, made from PRISTINE databases ALONE.

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
LHS is ALWAYS golden; RHS is ALWAYS ours.

This reads ONE censweep113 `rows.tsv` -- the golden half and OUR PRISTINE half
of a sweep, and nothing from any patched database -- and names, BY NAME, every
database the law can reach and every cell it will move.  It is run and its
output frozen BEFORE the patched sweep, so the measurement can only confirm or
refute it.

THE GATE, stated exactly as the code states it (§ genScopeCaPatNoFirstSize113):

  * family PX (an assignment-pattern operation's FIRST operand),
  * `sc=gen_scope`   -- the operation is inside an elaborated generate scope,
  * `car=cont_assign`-- carried by a continuous assign (not a process, not a
                        param_assign),
  * `lhs=ref_obj...` -- the assign's target is a plain named reference, so
                        Surelog's `writeCont_assign` reaches `bindVariable` at
                        all,
  * `/decl=gen_scope`-- and the target is DECLARED IN THE GENERATE SCOPE, which
                        is the fence: `bindVariable` (CompileStmt.cpp:3089-3148)
                        has no `gen_scope` case and recurses to the parent, so a
                        MODULE-BODY target is found even from inside a generate
                        block and golden sizes operand 0 exactly as at module
                        scope (uhdm2rtlil `gen_struct_access`, Surelog
                        `FuncAlias`),
  * the operand kind is not `tagged_pattern` (an unflattened pattern has no
    first operand of ours to stamp), and
  * it is not an UNSIZED constant -- `flattenPatternAssignments` itself resizes
    a tagged constant at `VpiSize == -1` to the field width, which is the same
    number this stamp writes.

PREDICTED NEW VALUE.  Where golden holds the SAME operand kind at the same
coordinate, golden's payload IS the predicted patched payload: golden never
stamps there, and suppressing the stamp leaves the operand at its natural size.
Cells whose gate matches but whose payload already equals golden's are named as
NO-OP (the stamp wrote the size the operand already had); cells with no golden
counterpart are named as NOGOLD (earl45's lesson -- counted and named, never
folded into a win or a loss).

  usage: predict113.py <rows.tsv>
"""
import sys
from collections import defaultdict


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    gold = defaultdict(set)
    ours = defaultdict(set)
    for line in open(sys.argv[1]):
        p = line.rstrip('\n').split('\t')
        if len(p) < 5:
            continue
        side, row, key, pay = p[0], p[1], p[2], p[3]
        if not key.startswith('PX|'):
            continue
        (gold if side == 'G' else ours)[(row, key)].add(pay)

    move, noop, nogold = [], [], []
    risk = 0
    for k in sorted(ours):
        row, key = k
        if 'sc=gen_scope' not in key or 'car=cont_assign' not in key:
            continue
        if 'lhs=ref_obj' not in key or '/decl=gen_scope' not in key:
            continue
        kind = key.rsplit('|k=', 1)[-1]
        if kind == 'tagged_pattern':
            continue
        if kind == 'constant' and all('sz=-1' in x for x in ours[k]):
            continue
        risk += 1
        g = gold.get(k)
        if g is None:
            nogold.append(k)
        elif g == ours[k]:
            noop.append(k)
        else:
            move.append(k)

    print('--- GATE-MATCHING cells: %d ---' % risk)
    print('--- PREDICTED MOVE cells: %d ---' % len(move))
    for row, key in move:
        print('MOVE\t%s\t%s\n\tfrom %s\n\tto   %s' %
              (row, key, sorted(ours[(row, key)]), sorted(gold[(row, key)])))
    print('--- PREDICTED NO-OP cells (gate matches, payload already golden):'
          ' %d ---' % len(noop))
    for row, key in noop:
        print('NOOP\t%s\t%s' % (row, key))
    print('--- NOGOLD cells (gate matches, golden has no operand of this kind):'
          ' %d ---' % len(nogold))
    for row, key in nogold:
        print('NOGOLD\t%s\t%s\n\tours %s' % (row, key,
                                             sorted(ours[(row, key)])))
    rows = sorted({r for r, _ in move} | {r for r, _ in nogold})
    print('ROWS PREDICTED TO MOVE (%d):' % len(rows))
    for r in rows:
        print('  %s' % r)
    return 0


if __name__ == '__main__':
    sys.exit(main())
