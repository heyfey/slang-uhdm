#!/usr/bin/env python3
"""r10oth8 -- the ARM TABLE builder: one row per cell, BOTH SIDES, OWN DEPTH.

    usage: ct8grid.py <g.dump> <o.dump> <field> [name-prefix]

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours -- the first dump argument is
golden, the second is ours, matching `uhdm-cmp <golden.uhdm> <ours.uhdm>`.

For every `array_var` whose name starts with <name-prefix> (default `a`), prints
FOUR cells: the field's value on the array_var's OWN depth and on its NESTED
element, for golden and for ours.  A field that is ABSENT prints `-`; a cell
whose object does not exist AT ALL on that side prints `UNMEASURED`, which is a
DIFFERENT and louder reading than `-` because a missing object and an absent
field are different defects.

This separation is the whole point: golden puts `vpiSigned` on the ARRAY_VAR and
ours puts it on the element var, and an instrument that flattens the subtree
reports that as a REORDER instead of a MOVE (the r10oth8 brief records exactly
that error being made on this target).
"""
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from ct8fields import HDR, objects, own_and_nested  # noqa: E402


def side(dump, prefix):
    # A MISSING dump is a MEASUREMENT FAILURE, not an empty side.  The first
    # draft of this script raised FileNotFoundError when an arm's own side had
    # not been produced (slang rejected the source), which prints a traceback
    # where the table should be -- and a traceback is not a reading.  Every
    # unresolvable cell in this pass prints UNMEASURED instead.
    try:
        with open(dump, encoding='utf-8', errors='replace') as fh:
            lines = fh.readlines()
    except OSError as e:
        print('UNMEASURED: cannot read dump %s (%s)' % (dump, e.strerror))
        return None
    cells = {}
    for i, ind, hdr in objects(lines, 'array_var', ''):
        own, refs, nested = own_and_nested(lines, i, ind)
        nm = dict(own).get('vpiName')
        if not nm or not nm.startswith(prefix):
            continue
        # Keep the DEFINITIONAL occurrence (see ct8fields.py --defn).
        if nm in cells and len(cells[nm][0]) >= len(own):
            continue
        cells[nm] = (own, nested, hdr)
    return cells


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        return 2
    g, o, field = sys.argv[1], sys.argv[2], sys.argv[3]
    prefix = sys.argv[4] if len(sys.argv) > 4 else 'a'
    G, O = side(g, prefix), side(o, prefix)
    if G is None or O is None:
        print('UNMEASURED: one side has no dump; no arm table produced')
        return 3
    names = sorted(set(G) | set(O))
    if not names:
        print('UNMEASURED: no array_var named %s* on EITHER side' % prefix)
        return 3
    print('%-24s | %-9s %-9s | %-9s %-9s | %-7s %-7s | verdict' %
          ('cell', 'G.own', 'O.own', 'G.nested', 'O.nested', 'G.aType', 'O.aType'))
    bad = 0
    for n in names:
        def cell(D):
            if n not in D:
                return ('UNMEASURED', 'UNMEASURED', 'UNMEAS')
            own, nested, _ = D[n]
            ov = dict(own).get(field, '-')
            nv = '-'
            for ow, fn, fv in nested:
                if fn == field:
                    nv = '%s=%s' % (ow.replace('_var', ''), fv)
                    break
            return (ov, nv, dict(own).get('vpiArrayType', '-'))
        go, gn, ga = cell(G)
        oo, on, oa = cell(O)
        v = 'EQ' if (go == oo and gn == on) else 'DIFF'
        if v == 'DIFF':
            bad += 1
        print('%-24s | %-9s %-9s | %-9s %-9s | %-7s %-7s | %s' %
              (n, go, oo, gn, on, ga, oa, v))
    print('---- cells=%d differing=%d field=%s' % (len(names), bad, field))
    return 0


if __name__ == '__main__':
    sys.exit(main())
