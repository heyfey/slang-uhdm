#!/usr/bin/env python3
"""r11u34: list every assignment-pattern operation in a uhdm-dump, with its
section (DEF/ELAB listing by |uhdm* header), depth, location and vpiSize.
usage: sz.py <dump> [<dump2>]"""
import re, sys

def rows(path):
    sect = '?'
    out = []
    lines = open(path).read().splitlines()
    for i, ln in enumerate(lines):
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m:
            sect = m.group(1)
            continue
        m = re.match(r'^(\s*)\\_operation: , (line:[\d:]+, endln:[\d:]+)', ln)
        if not m:
            continue
        ind = len(m.group(1))
        loc = m.group(2)
        # read the field lines that belong to this object (indent == ind+2, '|')
        size = None; optype = None
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            k = len(l2) - len(l2.lstrip())
            if k < ind + 2 or (k == ind + 2 and not l2.lstrip().startswith('|')):
                if k <= ind:
                    break
            if k == ind + 2 and l2.lstrip().startswith('|vpiSize:'):
                size = l2.split(':')[-1]
            if k == ind + 2 and l2.lstrip().startswith('|vpiOpType:'):
                optype = l2.split(':')[-1]
            if k <= ind:
                break
            j += 1
        if optype in ('75', '76'):
            out.append((sect, ind, loc, optype, size))
    return out

for p in sys.argv[1:]:
    print('==', p)
    for r in rows(p):
        print('   sect=%-16s ind=%-3d %s op=%s size=%s' % r)
