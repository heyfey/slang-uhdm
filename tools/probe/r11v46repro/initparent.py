#!/usr/bin/env python3
# For every gen_for init assignment in a uhdm-dump, print the Rhs object kind
# and whether that Rhs carries a |vpiParent: line.
import re, sys
lines = open(sys.argv[1], errors='replace').read().split('\n')
i = 0
while i < len(lines):
    if lines[i].strip() == '|vpiForInitStmt:':
        # the assignment object
        j = i + 1
        ind = len(lines[j]) - len(lines[j].lstrip())
        aline = lines[j].strip()
        # find |vpiRhs: within this assignment's block
        k = j + 1
        while k < len(lines):
            t = lines[k]
            if t.strip() == '':
                break
            if len(t) - len(t.lstrip()) <= ind and not t.strip().startswith('|'):
                break
            if t.strip() == '|vpiRhs:':
                r = lines[k + 1]
                rind = len(r) - len(r.lstrip())
                has_parent = (k + 2 < len(lines) and
                              lines[k + 2].strip() == '|vpiParent:')
                print("%-42s RHS=%-58s parent=%s" %
                      (aline[:42], r.strip()[:58], 'YES' if has_parent else 'no'))
                break
            k += 1
        i = j
    i += 1
