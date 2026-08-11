#!/usr/bin/env python3
"""Print the ANCESTOR CHAIN of a given line number in a uhdm-dump.

usage: anc.py <dump> <lineno> [<lineno> ...]

The two candidate source files in the YosysOldOr target are byte-identical at
line 113, so no TEXTUAL measurement can say which of the five `range
113:8-113:16` objects is which -- the brief's own instruction was "an id walk or
instrumentation, NOT dump grepping".  This walks the dump's indentation upward
from a line and prints every enclosing object header plus the last view marker,
which names the instance the object belongs to.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours -- one dump at a time.
"""
import sys


def ind(s):
    return len(s) - len(s.lstrip(' '))


def main():
    path = sys.argv[1]
    lines = open(path).read().split('\n')
    for arg in sys.argv[2:]:
        n = int(arg) - 1          # grep -n is 1-based
        print('===== %s:%s  %s' % (path, arg, lines[n].strip()[:100]))
        chain = []
        cur = ind(lines[n])
        i = n - 1
        view = '?'
        while i >= 0:
            ln = lines[i]
            if ln.startswith('|uhdm'):
                view = ln.strip()
                break
            st = ln.strip()
            if st.startswith('\\_') and ind(ln) < cur:
                chain.append((ind(ln), st[:100]))
                cur = ind(ln)
            i -= 1
        print('   view: ' + view)
        for d, s in reversed(chain):
            print('   %s%s' % (' ' * d, s))


main()
