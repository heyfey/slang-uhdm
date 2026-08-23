#!/usr/bin/env python3
"""r10buvm26 — PREDICT the § droppedIdxRecvCall26 movers, from the PRISTINE
databases only, BY NAME, before the patched sweep runs.

MEASUREMENT ONLY.  LHS is ALWAYS golden, RHS is ALWAYS ours.

A site of this law is one where

  * GOLDEN holds a two-element `hier_path` [`bit_select`, `method_func_call`]
    (the shape `CompileExpression.cpp:5455`'s loop builds for
    `recv[idx].meth()` in expression position), and
  * OURS holds, INSIDE that path's span, a bare `bit_select` of the SAME
    `vpiName` whose parent is NOT a hier_path — i.e. the call was dropped;
  * and OURS has NO hier_path of that shape at that span.

or, in statement position,

  * GOLDEN holds a `method_func_call` whose `vpiPrefix` is named `<base>` and
    OURS holds a bare `bit_select` named `<base>` spanning inside it.

Rows are TAB-separated: a hier_path name can contain spaces (a prettyPrinted
operation index), and a space-split join shifted exactly those rows.

The join is by LOCATION ONLY: our expression nodes carry an EMPTY `VpiFile`
(buvm16 §4), so a file-keyed join would drop every row.  Rows are a MULTISET,
never a last-writer dict (RESUME.md §9).

usage: predict26.py <golden.cen> <ours.cen>
"""
import collections
import sys


def rd(path):
    out = collections.defaultdict(list)
    with open(path, errors='replace') as fh:
        for line in fh:
            f = line.rstrip('\n').split('\t')
            if len(f) < 4:
                continue
            out[f[1]].append(f[2:])
    return out


def sp(t):
    a, b = t.split('-')
    al, ac = (int(x) for x in a.split(':'))
    bl, bc = (int(x) for x in b.split(':'))
    return (al, ac), (bl, bc)


def inside(outer, inner):
    (a0, a1), (b0, b1) = sp(outer)
    (c0, c1), _ = sp(inner)
    return a0 <= c0 <= b0 and (a0, a1) <= (c0, c1) <= (b0, b1)


def main():
    g, o = rd(sys.argv[1]), rd(sys.argv[2])
    ourhp = {r[0] for r in o['HP']}
    ourbs = o['BS']
    hits = []
    for r in g['HP']:
        spn, pname, e0, e1, pk = r[0], r[1], r[2], r[3], r[4]
        if spn in ourhp:
            continue
        base = e0.split('/', 1)[1]
        for b in ourbs:
            if b[1] == base and b[2] != 'hier_path' and inside(spn, b[0]):
                hits.append('EXPR %s %s -> %s (%s)' % (spn, pname, e1, pk))
                break
    print('GOLDEN 2-elem hier_paths: %d   OURS: %d   PREDICTED MOVERS: %d'
          % (len(g['HP']), len(o['HP']), len(hits)))
    for h in sorted(hits):
        print('  ' + h)


if __name__ == '__main__':
    main()
