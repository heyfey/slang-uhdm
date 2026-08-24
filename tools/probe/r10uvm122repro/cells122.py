#!/usr/bin/env python3
"""r10uvm122 — census of every `ref_obj` in a uhdm-dump and the OBJECT its
`vpiActual` names.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.

One row per DISTINCT (VpiName-of-the-ref, ref span, actual kind, actual span),
with the multiplicity, so a multiset join can never drop a colliding key.  The
dump SYNTHESIZES vpiFullName from the parent chain, so the key uses the ref's
printed name plus its own span, never a fullname and never a file path.

  usage: cells122.py <dump> [name-substring]
"""
import sys, re
from collections import Counter

REF = re.compile(r'_(ref_obj|ref_var): \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)')
OBJ = re.compile(r'\\_([a-z_]+): (.*)$')
SPAN = re.compile(r'(line:\d+:\d+, endln:\d+:\d+)')
NAME = re.compile(r'\(([^)]*)\)')


def actual_of(lines, i):
    """The object named under this ref's vpiActual, or '<none>'.

    The scan stops at the NEXT object header at the ref's own indent or
    shallower, so a ref with no vpiActual can never borrow a sibling's.
    """
    base = len(lines[i]) - len(lines[i].lstrip())
    for j in range(i + 1, len(lines)):
        l = lines[j]
        ind = len(l) - len(l.lstrip())
        if l.strip().startswith('\\_') and ind <= base:
            return '<none>'
        if ind <= base and l.strip().startswith('|') is False and l.strip():
            return '<none>'
        if l.strip() == '|vpiActual:':
            m = OBJ.search(lines[j + 1])
            if not m:
                return lines[j + 1].strip()
            kind, rest = m.group(1), m.group(2)
            nm = NAME.search(rest)
            sp = SPAN.search(rest)
            return '%s %s %s' % (kind, nm.group(1) if nm else '',
                                 sp.group(1) if sp else '')
    return '<none>'


def main():
    dump = open(sys.argv[1], errors='replace').read().split('\n')
    want = sys.argv[2] if len(sys.argv) > 2 else ''
    rows = Counter()
    for i, l in enumerate(dump):
        m = REF.search(l)
        if not m:
            continue
        nm = m.group(2)
        if want and want not in nm:
            continue
        rows[(m.group(1), nm, '%s:%s-%s:%s' % m.group(3, 4, 5, 6),
              actual_of(dump, i))] += 1
    for k in sorted(rows):
        print('%d\t%s\t%s\t%s\t%s' % (rows[k], k[0], k[1], k[2], k[3]))


main()
