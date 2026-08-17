#!/usr/bin/env python3
"""r10buvm3 — SPAN-KEYED CELL TABLE for an arm's two dumps.

For every `typespec_member: (<name>)` in a dump, report the object its
`vpiTypespec` -> `ref_typespec` -> `vpiActual` names, keyed by the MEMBER NAME
plus its span (a name alone is ambiguous the moment two containers reuse it).
Prints GOLDEN and OURS side by side and marks each cell EQ / NE, so a grid is
read as a table of measured cells instead of a diff a human has to align.

  usage: cells.py <g.dump> <o.dump> [name-substring ...]
"""
import re, sys

MEM = re.compile(r'^(\s*)\\_typespec_member: \((.*?)\), line:(\d+):(\d+)')

def scan(path):
    out = {}
    lines = open(path).read().split('\n')
    for i, ln in enumerate(lines):
        m = MEM.match(ln)
        if not m:
            continue
        indent, name, l, c = m.group(1), m.group(2), m.group(3), m.group(4)
        # walk forward inside this member's block for the FIRST vpiActual
        # The ref_typespec nested under this member carries a vpiParent
        # BACK-REFERENCE to the member itself, so "stop at the next
        # typespec_member" must compare INDENT: only a line at or LEFT of this
        # member's own indent starts a new one.  Getting that wrong made every
        # cell read None -- a table of Nones compares EQ everywhere and reads
        # exactly like a clean grid.
        act = None
        seen_ts = False
        for j in range(i + 1, min(i + 60, len(lines))):
            nx = lines[j]
            ind = len(nx) - len(nx.lstrip())
            st = nx.strip()
            if ind <= len(indent) and st.startswith('\\_typespec_member:'):
                break
            if ind <= len(indent) and st.startswith('|vpiTypespecMember:'):
                break
            if st == '|vpiTypespec:':
                seen_ts = True
            if seen_ts and st == '|vpiActual:':
                act = lines[j + 1].strip()
                break
        key = (name, int(l), int(c))
        out.setdefault(key, act)
    return out

g, o = scan(sys.argv[1]), scan(sys.argv[2])
pats = sys.argv[3:]
keys = sorted(set(g) | set(o))
neq = 0
print(f'{"MEMBER":22} {"@LINE:COL":10} {"VERDICT":8} GOLDEN | OURS')
for k in keys:
    if pats and not any(p in k[0] for p in pats):
        continue
    a, b = g.get(k), o.get(k)
    v = 'EQ' if a == b else 'NE'
    if v == 'NE':
        neq += 1
    print(f'{k[0]:22} {k[1]}:{k[2]:<8} {v:8} {a} | {b}')
print(f'-- cells={len(keys)} NE={neq}')
