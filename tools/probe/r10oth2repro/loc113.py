#!/usr/bin/env python3
"""Locate every `range: , line:113:8, endln:113:16` in a uhdm-dump and report,
for each, whether its LeftRange is the UNFOLDED `operation 113:9-113:13` or the
FOLDED `constant 113:9-113:11`, together with the nearest ENCLOSING named object
printed above it (the last line at a strictly smaller indent that carries a
`(name)` or a `module_inst:`/`port:` tag).

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours -- run one dump at a time.
"""
import re
import sys


def ind(s):
    return len(s) - len(s.lstrip(' '))


for path in sys.argv[1:]:
    lines = open(path).read().split('\n')
    print('===== ' + path)
    # remember, per indent level, the most recent header line
    stack = {}
    counts = {}
    for i, ln in enumerate(lines):
        st = ln.strip()
        if st.startswith('\\_') or st.startswith('|uhdm'):
            stack[ind(ln)] = (i, st[:110])
        m = re.match(r'^\s*\\_range: , line:113:8, endln:113:16$', ln)
        if not m:
            continue
        base = ind(ln)
        form = '?'
        for j in range(i + 1, min(i + 12, len(lines))):
            if 'operation: , line:113:9, endln:113:13' in lines[j]:
                form = 'UNFOLDED-op'
                break
            if 'constant: , line:113:9, endln:113:11' in lines[j]:
                form = 'FOLDED-const'
                break
            if ind(lines[j]) <= base and lines[j].strip().startswith('\\_'):
                break
        # nearest enclosing headers, outermost first
        ctx = [v[1] for k, v in sorted(stack.items()) if k < base]
        ctx = ' / '.join(ctx[-3:]) if ctx else '(weak tail, no parent)'
        key = (form, ctx)
        counts[key] = counts.get(key, 0) + 1
    for (form, ctx), n in sorted(counts.items()):
        print(f'  {n:3d}x {form:13s} in {ctx}')
