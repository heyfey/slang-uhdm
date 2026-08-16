#!/usr/bin/env python3
"""r10sd1 — WHOLE-DESIGN CELL GRID for class_typespec specializations.

One CELL = one `(vpiName, span)` key of a `class_typespec`.  Its VALUE is the
pair `(has vpiParameter, has vpiParamAssign)` read from the object's FULL print
(uhdm-dump prints each object's body exactly once; every later appearance is a
header line only, so a naive grep sees "no children" for 200 of 206 copies and
would report a deficit that is not there).

    usage: cells.py <golden.dump> <ours.dump> [--kind class_typespec]

Prints one row per key present in EITHER dump:
    SAME / DIFF / GOLDEN-ONLY / OURS-ONLY   key   golden=(P,A)  ours=(P,A)
then per-status counts.

WHY (P,A) AND NOT THE WHOLE SUBTREE: `class_typespec::Compare` reads exactly
`Parameters` and `Param_assigns` among the fields this pass can move, and the
`rhs == nullptr` arm of the vector `SafeCompare` reports the CONTAINER with
`RHS: <null>` -- indistinguishable in cmp.log from a missing singular object.
This grid is what tells the two apart.

GUARDS:
  * a key present on ONE side only is GOLDEN-ONLY / OURS-ONLY and is NEVER
    counted SAME -- an "empty product" cell (agreement that costs nothing) can
    otherwise inflate the SAME column.
  * both dumps must be non-empty (exit 6): two empty inputs agree perfectly.
"""
import re
import sys
from collections import OrderedDict

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): ?(.*)$')
LBL = re.compile(r'^(\s*)\|([A-Za-z0-9_]+):')


def scan(path, kind):
    lines = open(path, errors='replace').read().split('\n')
    if len(lines) < 10:
        print('NO_OUTPUT: %s' % path, file=sys.stderr)
        sys.exit(6)
    cells = OrderedDict()
    i = 0
    n = len(lines)
    while i < n:
        om = OBJ.match(lines[i])
        if om and om.group(2) == kind:
            ind = len(om.group(1))
            body = om.group(3)
            nm = re.match(r'^\(([^)]*)\)', body)
            name = nm.group(1) if nm else ''
            sm = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', body)
            span = '%s:%s-%s:%s' % sm.groups() if sm else '-'
            # children of a FULL print sit at ind+2; a header-only repeat has
            # its next line at <= ind.
            labels = set()
            j = i + 1
            while j < n:
                lm = LBL.match(lines[j])
                om2 = OBJ.match(lines[j])
                cur = len(lm.group(1)) if lm else (len(om2.group(1)) if om2 else -1)
                if cur < 0 or cur <= ind:
                    break
                if lm and cur == ind + 2:
                    labels.add(lm.group(2))
                j += 1
            key = (name, span)
            val = ('P' if 'vpiParameter' in labels else '-',
                   'A' if 'vpiParamAssign' in labels else '-')
            if j > i + 1 or key not in cells:
                # only a FULL print (j>i+1) may set the value; a header-only
                # repeat seeds the key but never overwrites a real reading
                if key in cells and j == i + 1:
                    pass
                else:
                    cells[key] = val
            i = j
            continue
        i += 1
    return cells


def main():
    kind = 'class_typespec'
    if '--kind' in sys.argv:
        kind = sys.argv[sys.argv.index('--kind') + 1]
    g = scan(sys.argv[1], kind)
    o = scan(sys.argv[2], kind)
    keys = list(g.keys()) + [k for k in o if k not in g]
    tally = {}
    for k in keys:
        if k in g and k in o:
            st = 'SAME' if g[k] == o[k] else 'DIFF'
        elif k in g:
            st = 'GOLDEN-ONLY'
        else:
            st = 'OURS-ONLY'
        tally[st] = tally.get(st, 0) + 1
        if st != 'SAME':
            print('%-12s %-46s %-24s G=%s  O=%s'
                  % (st, k[0][:46], k[1],
                     ''.join(g.get(k, ('?', '?'))), ''.join(o.get(k, ('?', '?')))))
    print('--- keys=%d  ' % len(keys) + '  '.join(
        '%s=%d' % (s, tally[s]) for s in sorted(tally)))


main()
