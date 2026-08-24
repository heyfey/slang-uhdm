#!/usr/bin/env python3
"""r10v122 (verifier) — census of every ref_obj/ref_var and the object its
vpiActual names.  Payload is COMPARE-VISIBLE ONLY: the actual's KIND and its
printed NAME.  Spans are recorded in a SECOND column so a span-only move is
visible but never counted as a Compare move.  Key = (ref kind, ref name,
ref span) with multiplicity, so a multiset join drops nothing.
  usage: v122cells.py <dump> [name-substring]
"""
import sys, re
from collections import Counter

REF = re.compile(r'_(ref_obj|ref_var): \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)')
OBJ = re.compile(r'\\_([a-z_]+): (.*)$')
SPAN = re.compile(r'(line:\d+:\d+, endln:\d+:\d+)')
NAME = re.compile(r'\(([^)]*)\)')


def actual_of(lines, i):
    base = len(lines[i]) - len(lines[i].lstrip())
    for j in range(i + 1, len(lines)):
        l = lines[j]
        ind = len(l) - len(l.lstrip())
        if l.strip().startswith('\\_') and ind <= base:
            return ('<none>', '')
        if ind <= base and not l.strip().startswith('|') and l.strip():
            return ('<none>', '')
        if l.strip() == '|vpiActual:':
            if j + 1 >= len(lines):
                return ('<trunc>', '')
            m = OBJ.search(lines[j + 1])
            if not m:
                return (lines[j + 1].strip(), '')
            kind, rest = m.group(1), m.group(2)
            nm = NAME.search(rest)
            sp = SPAN.search(rest)
            return ('%s %s' % (kind, nm.group(1) if nm else ''),
                    sp.group(1) if sp else '')
    return ('<none>', '')


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
        a, sp = actual_of(dump, i)
        rows[(m.group(1), nm, '%s:%s-%s:%s' % m.group(3, 4, 5, 6), a, sp)] += 1
    for k in sorted(rows):
        print('%d\t%s\t%s\t%s\t%s\t%s' % (rows[k], k[0], k[1], k[2], k[3], k[4]))


main()
