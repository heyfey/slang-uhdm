#!/usr/bin/env python3
"""r10earl114 -- THE MOVER PREDICTION, made from PRISTINE databases ALONE.

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
LHS is ALWAYS golden; RHS is ALWAYS ours.

This reads ONE `censweep114` `rows.tsv` -- the GOLDEN half and OUR PRISTINE half
of a sweep, and nothing from any patched database -- and names, BY NAME, every
database the law can reach, every cell it will move, and the exact payload each
moved cell will carry.  It is run and its output FROZEN before the patched
sweep, so the measurement can only confirm or refute it.

THE GATE, stated exactly as the code states it (§ patHierPathRootTs114, the
`flattenPatternCaRhs` Root_value loop in src/ModuleEmit.cpp):

  * family PX -- the hier_path's PARENT is an assignment-pattern operation
    (`flattenPatternCaRhs` walks `op->Operands()` and touches nothing else);
  * `sc=gen_scope` and `car=cont_assign` -- the emitter site is reached only
    from `emitBlock`'s ELABORATED generate-scope continuous-assign arm, which
    is Surelog's own gate `instance && reduce == Reduce::Yes`
    (CompileExpression.cpp:3688 sets `Reduce::Yes` inside
    `compileAssignmentPattern` when `instance` is non-null; a MODULE-BODY
    cont_assign is compiled once with `instance == nullptr` and golden binds
    nothing there -- arm t2 cells c8/c9);
  * `rv=` is BOUND -- the site hangs the typespec off the very object it
    already binds as `Root_value`, so a path whose root is absent from the
    emitter's `netMap` is not reached at all;
  * `rdecl=` is NOT `gen_scope` -- THE GENERATE-LOCAL ROOT FENCE: `getObject`
    (CompileExpression.cpp:150-232) searches array_nets / nets / variables /
    ports / param_assigns and never `array_vars()`, and a generate instance's
    netlist is exactly what `NetlistElaboration::elab_generates_` fills, so a
    root DECLARED IN A GENERATE BLOCK is not answered by name and golden binds
    neither field (arm t1 cells r4/r5/r9/r10);
  * `rts=` is not `<none>` -- Surelog copies `expval->Typespec()`'s
    `Actual_typespec`, so a root with no typespec of its own (every
    `array_net` root: arm t1 cells r3/r6/r8) hangs nothing on either side;
  * and the path does not already carry a Typespec.

PREDICTED NEW PAYLOAD.  The code mints a NAMELESS `ref_typespec` whose
`Actual_typespec` is the ROOT's own, so the new payload is
`ts=ref_typespec(n='',dn='')-><the rts recorded in the key>` -- constructed
here from the PRISTINE key alone and compared afterwards against what the
patched census actually holds.

Cells whose gate matches but whose payload already equals golden's are named
NO-OP; cells with no golden counterpart are named NOGOLD (earl45's lesson --
counted and named, never folded into a win or a loss).

  usage: predict114.py <rows.tsv>
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
        if '|rv=' not in key or '|rv=<none>' in key:
            continue
        if '/rdecl=gen_scope' in key:
            continue
        rts = key.rsplit('/rts=', 1)[-1]
        if rts == '<none>' or rts == 'notanexpr':
            continue
        if not all(x == 'ts=<none>' for x in ours[k]):
            continue
        risk += 1
        pred = "ts=ref_typespec(n='',dn='')->" + rts
        g = gold.get(k)
        if g is None:
            nogold.append((k, pred))
        elif g == {pred}:
            move.append((k, pred))
        elif g == ours[k]:
            noop.append(k)
        else:
            move.append((k, pred))

    print('--- GATE-MATCHING cells: %d ---' % risk)
    print('--- PREDICTED MOVE cells: %d ---' % len(move))
    for (row, key), pred in move:
        print('MOVE\t%s\t%s\n\tfrom %s\n\tto   [%r]\n\tgolden %s' %
              (row, key, sorted(ours[(row, key)]), pred,
               sorted(gold.get((row, key), []))))
    print('--- PREDICTED NO-OP cells (gate matches, payload already golden):'
          ' %d ---' % len(noop))
    for row, key in noop:
        print('NOOP\t%s\t%s' % (row, key))
    print('--- NOGOLD cells (gate matches, golden has no path at this key):'
          ' %d ---' % len(nogold))
    for (row, key), pred in nogold:
        print('NOGOLD\t%s\t%s\n\tours %s\n\tto   [%r]' %
              (row, key, sorted(ours[(row, key)]), pred))
    rows = sorted({r for (r, _), _ in move} | {r for (r, _), _ in nogold})
    print('ROWS PREDICTED TO MOVE (%d):' % len(rows))
    for r in rows:
        print('  %s' % r)
    return 0


if __name__ == '__main__':
    sys.exit(main())
