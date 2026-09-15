#!/usr/bin/env python3
"""r11u34: for each param_assign in a uhdm-dump, print the section, the Lhs
parameter name, the Rhs operation's opType, whether it carries a vpiTypespec
(and what the ref's name/actual are), and the operand kinds+sizes.
usage: ts.py <dump>..."""
import re, sys

def walk(path):
    lines = open(path).read().splitlines()
    sect = '?'
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m:
            sect = m.group(1); i += 1; continue
        m = re.match(r'^(\s*)\\_param_assign: , (line:[\d:]+)', ln)
        if not m:
            i += 1; continue
        ind = len(m.group(1))
        # collect the block
        j = i + 1
        blk = []
        while j < len(lines):
            l2 = lines[j]
            k = len(l2) - len(l2.lstrip())
            if k <= ind and l2.strip():
                break
            blk.append(l2); j += 1
        name = ''
        for a, l2 in enumerate(blk):
            if l2.strip() == '|vpiLhs:' and a + 1 < len(blk):
                mm = re.search(r'\((.*?)\)', blk[a + 1])
                if mm: name = mm.group(1)
        # Rhs object: first line after |vpiRhs:
        rhs = ''
        rind = None
        for a, l2 in enumerate(blk):
            if l2.strip() == '|vpiRhs:' and a + 1 < len(blk):
                rhs = blk[a + 1].strip()
                rind = len(blk[a + 1]) - len(blk[a + 1].lstrip())
                rpos = a + 1
                break
        info = []
        if rind is not None:
            for l2 in blk[rpos + 1:]:
                k = len(l2) - len(l2.lstrip())
                if k <= rind and l2.strip():
                    break
                if k == rind + 2 and l2.lstrip().startswith(('|vpiOpType:', '|vpiSize:', '|vpiTypespec:', '|vpiReordered:')):
                    info.append(l2.strip())
                if k == rind + 2 and l2.lstrip().startswith('|vpiOperand:'):
                    info.append('|op')
                if k == rind + 4 and l2.lstrip().startswith('\\_'):
                    info.append('  ' + l2.strip()[:70])
        print('%-18s %-28s %s' % (sect, name, rhs[:60]))
        for x in info[:24]:
            print('        ' + x)
        i = j

for p in sys.argv[1:]:
    print('==', p); walk(p)
