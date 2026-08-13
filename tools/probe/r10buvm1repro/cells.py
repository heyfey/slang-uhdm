#!/usr/bin/env python3
"""r10buvm1 CELL READER — golden beside ours, one row per SOURCE LINE.

    usage: cells.py <g.dump> <o.dump> <first-line> <last-line> [srcfile]

Each cell of arm a1/a2 is exactly one written statement on one source line, so
the honest key is the LINE NUMBER, not an object identity that the two sides
are allowed to disagree about (that is the whole thing being measured).  For
each line in the window this prints, for BOTH sides, the multiset of
`kind(name)@col-endcol` shapes that dump at that line — deduplicated because
uhdm-dump prints an object once per listing view and a count difference between
the views is not a model difference.

LHS is ALWAYS golden; RHS is ALWAYS ours.  A line where the two columns differ
is a DIFFERING CELL and is marked `*`.

Both dumps must already have uhdm-dump's first line (the database path)
stripped.  Missing/empty input is exit 6, never an empty table.
"""
import os
import re
import sys

OBJ = re.compile(r'^\s*(?:\\_)?([a-z_0-9]+): \(([^)]*)\), line:(\d+):(\d+), '
                 r'endln:(\d+):(\d+)')
OBJ_NONAME = re.compile(r'^\s*(?:\\_)?([a-z_0-9]+): , line:(\d+):(\d+), '
                        r'endln:(\d+):(\d+)')


def shapes(path, lo, hi):
    out = {}
    try:
        with open(path) as f:
            data = f.read().splitlines()
    except OSError:
        sys.exit(6)
    if not data:
        sys.exit(6)
    for ln in data:
        m = OBJ.match(ln)
        if m:
            kind, name, l, c, el, ec = m.groups()
            name = name.split('::')[-1] if '::' in name else name
            full = m.group(2)
            tail = '::'.join(full.split('::')[-2:]) if '::' in full else full
        else:
            m = OBJ_NONAME.match(ln)
            if not m:
                continue
            kind, l, c, el, ec = m.groups()
            tail = ''
        l = int(l)
        if l < lo or l > hi:
            continue
        out.setdefault(l, set()).add('%s(%s)@%s-%s' % (kind, tail, c, ec)
                                     if el == str(l) else
                                     '%s(%s)@%s-%s:%s' % (kind, tail, c, el, ec))
    return out


def strip_spans(st):
    return {re.sub(r'@.*$', '', x) for x in st}


def main():
    """SPANBLIND=1 compares the SHAPE alone (object kind + name), with every
    span erased.  Reporting both numbers is the honest split: a cell whose kind
    and name reach golden and whose span does not is a DIFFERENT finding from a
    cell that still holds the wrong object, and one number cannot say which."""
    if len(sys.argv) < 5:
        sys.exit(__doc__)
    g = shapes(sys.argv[1], int(sys.argv[3]), int(sys.argv[4]))
    o = shapes(sys.argv[2], int(sys.argv[3]), int(sys.argv[4]))
    if os.environ.get('SPANBLIND') == '1':
        g = {k: strip_spans(v) for k, v in g.items()}
        o = {k: strip_spans(v) for k, v in o.items()}
    src = {}
    if len(sys.argv) > 5:
        with open(sys.argv[5]) as f:
            for i, t in enumerate(f.read().splitlines(), 1):
                src[i] = t.strip()
    diff = 0
    for l in range(int(sys.argv[3]), int(sys.argv[4]) + 1):
        gs, os_ = g.get(l, set()), o.get(l, set())
        if not gs and not os_:
            continue
        mark = ' ' if gs == os_ else '*'
        if gs != os_:
            diff += 1
        print('%s line %-5d %s' % (mark, l, src.get(l, '')))
        print('      GOLDEN: %s' % ('  '.join(sorted(gs)) or '<nothing>'))
        print('      OURS  : %s' % ('  '.join(sorted(os_)) or '<nothing>'))
    print('DIFFERING CELLS: %d' % diff)


main()
