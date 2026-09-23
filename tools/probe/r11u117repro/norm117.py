#!/usr/bin/env python3
"""norm117.py <dump> — contextual cell normaliser: every dump line is keyed by
its design SECTION (|uhdmallPackages, |uhdmtopModules, ...) and its two
nearest enclosing OBJECT headers (kind + name + five-field span; ids and
workdir paths dropped), so a bare field line (`|vpiParent:`, `|vpiSize:36`) is
scored where it sits, and a nameless / parentless object is keyed by its own
kind+span and its owner.  Output unsorted; callers sort."""
import sys, re
L = open(sys.argv[1], errors='replace').read().split('\n')[1:]
def clean(s):
    s = re.sub(r', id:\d+', '', s)
    s = re.sub(r'file:[^,]*,', '', s)
    s = re.sub(r'/[^ ,]*/dut\.sv', 'dut.sv', s)
    return s.strip()
stack = []  # (indent, header)
sect = ''
for l in L:
    if not l.strip(): continue
    ind = len(l) - len(l.lstrip(' '))
    c = clean(l)
    if ind == 0 and c.startswith('|uhdm'): sect = c
    while stack and stack[-1][0] >= ind: stack.pop()
    ctx = ' / '.join(h for _, h in stack[-2:])
    print(sect + ' :: ' + ctx + ' >> ' + c)
    if c.startswith('\\_') or (not c.startswith('|') and ind == 0):
        stack.append((ind, c))
