#!/usr/bin/env python3
"""r10vrgg2/pos.py — locate the cell: the line:col of the integer literal on the
Rhs of the first statement-level compound assignment in a dut.sv.

Reading a cell at a HARD-CODED position is how a moved statement turns into a
silent UNMEASURED (or worse, into another object's value), so every arm's
position is derived from its own source."""
import re
import sys

pat = r'(\+=|-=|\*=|/=|<<=|%=)'
for i, l in enumerate(open(sys.argv[1]).read().split('\n'), 1):
    m = re.search(pat + r"\s+([0-9]+|[0-9]+'[a-zA-Z]?[0-9a-fA-F]+)\s*;", l)
    if m and 'function' not in l:
        print('%d:%d' % (i, m.start(2) + 1))
        break
