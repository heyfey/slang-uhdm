#!/usr/bin/env python3
"""r10uvm59repro/rhsown59.py — THE PER-OWNER FIELD PROVER.

    rhsown59.py <field> <span> <dump> [<dump> ...]

WHY THIS EXISTS.  `mv58.sh` keys its mover shapes on the dump line with the
INDENTATION STRIPPED, which is right for an OBJECT header (an object is not a
dump occurrence) and USELESS for a BARE FIELD LINE: `|vpiRhs:` carries no owner
at all once the depth is gone, so its multiplicity is a whole-database aggregate
and the attributor's `golden < ours` test reads OVER-FIRE on a database that
merely had a pre-existing surplus.  Pass 58 hit the identical artefact on
`|vpiSigned:1` and recorded the rule: NEVER ATTRIBUTE A BARE FIELD LINE.

This script does the attribution the honest way.  For a given field name and an
object SPAN it finds the object's STATEMENT occurrence — the one that carries the
field list rather than a back-reference — and reports the fields present at the
object's OWN CHILD DEPTH (header indent + 2), never anywhere in its subtree.  Run
it over golden, pristine and patched together and the answer is a table, not an
aggregate.

GUARDS: a span that matches no object prints NO-MATCH and is counted (a prover
that reaches nothing must not read as agreement); the discriminator field
(`vpiOpType` for an assignment) is required, so a back-reference listing can
never be mistaken for the real one.
"""
import sys


def fields_at_own_depth(path, span, need):
    lines = open(path, errors='replace').read().split('\n')
    key = ', line:%s,' % span
    for i, l in enumerate(lines):
        if '\\_' not in l or key not in l:
            continue
        ind = len(l) - len(l.lstrip())
        out = []
        for j in range(i + 1, min(i + 400, len(lines))):
            lj = lines[j]
            if not lj.strip():
                break
            ij = len(lj) - len(lj.lstrip())
            if ij <= ind:
                break
            if ij == ind + 2 and lj.lstrip().startswith('|'):
                out.append(lj.strip().split(':')[0][1:])
        if need in out:
            return out
    return None


def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    field, span, dumps = sys.argv[1], sys.argv[2], sys.argv[3:]
    nomatch = 0
    print('object @%s   field under test: %s' % (span, field))
    for d in dumps:
        f = fields_at_own_depth(d, span, 'vpiOpType')
        if f is None:
            print('   %-40s NO-MATCH (no occurrence carrying vpiOpType)' % d)
            nomatch += 1
            continue
        print('   %-40s %s=%-3s  fields=%s'
              % (d, field, 'YES' if field in f else 'NO', f))
    print('   NO-MATCH dumps: %d' % nomatch)


if __name__ == '__main__':
    main()
