#!/usr/bin/env python3
"""v11u34 SHAPE LISTER — every assignment-pattern operation in a uhdm-dump,
per SECTION, with its nesting depth and its vpiSize (or NOSIZE).

usage: lister.py <dump file> [section-substring]
"""
import re, sys


def walk(text):
    out = []
    sect = None
    stack = []
    lines = text.splitlines()
    for i, ln in enumerate(lines):
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m:
            sect = m.group(1)
            stack = []
            continue
        m = re.match(r'^(\s*)\\_operation: , (line:[\d:]+, endln:[\d:]+)', ln)
        if not m:
            continue
        ind = len(m.group(1))
        loc = m.group(2)
        size = None
        optype = None
        reord = None
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            k = len(l2) - len(l2.lstrip())
            if k <= ind:
                break
            if k == ind + 2 and l2.lstrip().startswith('|vpiSize:'):
                size = l2.split(':')[-1]
            if k == ind + 2 and l2.lstrip().startswith('|vpiOpType:'):
                optype = l2.split(':')[-1]
            if k == ind + 2 and l2.lstrip().startswith('|vpiReordered:'):
                reord = l2.split(':')[-1]
            j += 1
        while stack and stack[-1][0] >= ind:
            stack.pop()
        depth = sum(1 for _, p in stack if p)
        ispat = optype in ('75', '76')
        if ispat:
            out.append((sect, loc, depth, size, reord))
        stack.append((ind, ispat))
    return out


def main():
    text = open(sys.argv[1], errors='replace').read()
    filt = sys.argv[2] if len(sys.argv) > 2 else None
    for sect, loc, depth, size, reord in walk(text):
        if filt and filt not in sect:
            continue
        print('%-22s %-34s nest=%d size=%-6s reordered=%s'
              % (sect, loc, depth, size if size is not None else 'NOSIZE',
                 reord if reord is not None else '-'))


main()
