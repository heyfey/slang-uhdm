#!/usr/bin/env python3
"""r10earl116 — THE MOVER PREDICTION, made from PRISTINE databases only.

MEASUREMENT ONLY.  Reads the `sig116` census of a PRISTINE sweep (our side and
the golden side, both produced by `censweep116.sh` before the patched binary
exists) and names, BY ROW, every database § patCaFlatLhsWholeName116 can move.

THE GATE, RESTATED IN UHDM TERMS.  In slang the law refuses the early flatten
when the Lhs is not an `ExpressionKind::NamedValue`.  A NamedValue Lhs is
emitted as a plain `ref_obj`; an ElementSelect/RangeSelect as `bit_select` /
`var_select` / `part_select`; a MemberAccess as `hier_path`.  So on OUR pristine
database a cell the law can move is:

    scope is a gen_scope, carrier is a cont_assign,
    the Rhs is a vpiAssignmentPatternOp with NO tagged_pattern operand,
    and the Lhs object kind is NOT exactly `ref_obj`.

THE BOUND IS AN UPPER BOUND ON CELLS AND EXACT ON ROWS, AND THIS IS STATED
RATHER THAN HIDDEN.  A POSITIONAL pattern is emitted with un-tagged operands
too and is indistinguishable from an already-flattened keyed one in the
pristine database — arm `q2_car116` cell d2 is a real instance of that pair —
so a positional-pattern cell counts as a candidate here and does not move.  The
GOLDEN column below is the cross-check that removes the ambiguity: golden's own
TAGGED-ness at the same span is exactly what the patched binary will produce.

usage: predict116.py <pris.ours.txt> <pris.gold.txt>
"""
import sys
import collections


def load(path):
    rows = []
    for line in open(path):
        if not line.startswith('R|'):
            continue
        f = line.rstrip('\n').split('|')
        if len(f) < 13:
            continue
        rows.append(dict(db=f[1], span=f[2], lname=f[3], lk=f[4], lact=f[5],
                         sc=f[6], gd=f[7], car=f[8], nops=int(f[9]),
                         tag=int(f[10]), flat=f[11], opk=f[12]))
    return rows


def main(ours_path, gold_path):
    ours = load(ours_path)
    gold = load(gold_path)
    goldtag = {}
    for r in gold:
        goldtag.setdefault((r['db'], r['span'], r['lname']), set()).add(r['flat'])

    cand = [r for r in ours
            if r['sc'] == 'gen_scope' and r['car'] == 'cont_assign'
            and r['tag'] == 0 and r['nops'] > 0 and r['lk'] != 'ref_obj']
    rows = collections.Counter(r['db'] for r in cand)
    confirmed = [r for r in cand
                 if goldtag.get((r['db'], r['span'], r['lname'])) == {'TAGGED'}]
    crows = collections.Counter(r['db'] for r in confirmed)
    # the FENCE side: gen-scope cells the law KEEPS flattening.
    keep = [r for r in ours
            if r['sc'] == 'gen_scope' and r['car'] == 'cont_assign'
            and r['tag'] == 0 and r['nops'] > 0 and r['lk'] == 'ref_obj']

    print("OURS census rows                          : %d" % len(ours))
    print("CANDIDATE cells (upper bound)             : %d" % len(cand))
    print("CANDIDATE rows                            : %d" % len(rows))
    for db, n in sorted(rows.items()):
        print("    ROW %-46s cells=%d" % (db, n))
    print("GOLDEN-CONFIRMED cells (golden TAGGED)    : %d" % len(confirmed))
    print("GOLDEN-CONFIRMED rows                     : %d" % len(crows))
    for db, n in sorted(crows.items()):
        print("    ROW %-46s cells=%d" % (db, n))
    print("FENCED-KEEP cells (whole-name Lhs, stay flat): %d in %d rows"
          % (len(keep), len(set(r['db'] for r in keep))))
    byshape = collections.Counter((r['lk'], r['lact']) for r in cand)
    for k, n in sorted(byshape.items()):
        print("    CANDIDATE shape %-28s %d" % ('/'.join(k), n))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
