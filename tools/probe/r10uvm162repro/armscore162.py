#!/usr/bin/env python3
"""r10uvm162repro/armscore162.py — the THREE-WAY CELL SCORE for one grid arm.

For every class METHOD in the arm, cut the same slice out of golden (A), our
PRISTINE database (B) and our PATCHED one (C), normalise the workdir path and
the serializer ids away, and score the cell:

  RIGHT   B == A and C == A          (was right, still right)
  TOWARD  B != A and C == A          (was wrong, now right)
  WRONG   B == A and C != A          (was right, now wrong)   <- must be 0
  STILL   B != A, C != A, B == C     (untouched, still wrong)
  AWAY    B != A, C != A, B != C     (changed and still wrong) <- named, always
  ONLY-G  in A only
  ONLY-O  in B/C only
  ONLY-A  in B but NOT in C          (deleted by the patch)   <- must be 0

`--nospan` erases every `line:L:C, endln:L:C` before comparing, so a cell that
differs ONLY in a span — which no generated `Compare` reads (RESUME.md §9) —
is not counted as a difference.  Run it BOTH ways: with spans the score is the
dump's, without them it is the judge's.

`--rhs` narrows every cell to the FIRST assignment's `vpiRhs` payload, which is
the object this law builds.  The whole-method slice also carries r10uvm158's
block-span residue and, in the ELAB view, golden's own shared `ref_typespec`
actual — both PRE-EXISTING and at other objects, and both of which would
otherwise put a recovered cell in the "changed and still wrong" bucket for a
reason that has nothing to do with the operand list.  MEASUREMENT ONLY.

usage: armscore162.py <g.dump> <a.dump> <b.dump> [--nospan] [--rhs] [--list]
"""
import re
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from slice162 import slices  # noqa: E402
from twin162 import rhs  # noqa: E402


def key(lines, nospan):
    out = []
    for ln in lines:
        if nospan:
            # The span is DELETED, not replaced by a marker: our object often
            # carries NO span where golden carries one (r10uvm158's R1/R3), and
            # a marker would make that read as a difference the judge cannot
            # see — no generated `Compare` reads VpiLineNo/VpiColumnNo.
            ln = re.sub(r',?\s*line:\d+:\d+(, endln:\d+:\d+)?', '', ln)
        out.append(ln)
    return tuple(out)


def main():
    nospan = '--nospan' in sys.argv
    show = '--list' in sys.argv
    G, A, B = (slices(p) for p in sys.argv[1:4])
    if '--rhs' in sys.argv:
        G, A, B = ({n: rhs(v) for n, v in d.items() if rhs(v)}
                   for d in (G, A, B))
    tally = {k: 0 for k in
             ('RIGHT', 'TOWARD', 'WRONG', 'STILL', 'AWAY', 'ONLY-G', 'ONLY-O',
              'ONLY-A')}
    for n in sorted(set(G) | set(A) | set(B)):
        if n not in G:
            v = 'ONLY-O'
        elif n not in A and n not in B:
            v = 'ONLY-G'
        elif n in A and n not in B:
            v = 'ONLY-A'
        elif n not in A:
            v = 'ONLY-O'
        else:
            g, a, b = (key(x[n], nospan) for x in (G, A, B))
            if a == g and b == g:
                v = 'RIGHT'
            elif a != g and b == g:
                v = 'TOWARD'
            elif a == g and b != g:
                v = 'WRONG'
            elif a == b:
                v = 'STILL'
            else:
                v = 'AWAY'
        tally[v] += 1
        if show and v not in ('RIGHT',):
            print('%-8s %s' % (v, n))
    print('  '.join('%s=%d' % (k, tally[k]) for k in
                    ('RIGHT', 'TOWARD', 'WRONG', 'STILL', 'AWAY', 'ONLY-G',
                     'ONLY-O', 'ONLY-A')))


if __name__ == '__main__':
    main()
