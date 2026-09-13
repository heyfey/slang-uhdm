#!/usr/bin/env python3
"""shapes.py <golden.dump> <ours.dump> -- SIDE-BY-SIDE SHAPE LISTER.

The r11v7 lesson: a row-keyed census can read CLEAN across a real break,
because it scores VALUES and a break shows up in the SHAPE of the tree.  This
lists, per dump SECTION and per param_assign Lhs name, the Rhs OBJECT KIND
chain (kind plus the kinds of its immediate children) on both sides, and marks
every row where the shapes differ -- whether or not the values agree.
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_(\w+): ')
PAS = re.compile(r'^(\s*)\\_param_assign: ')
PAR = re.compile(r'^\s*\\_parameter: \((.*?)\)')


def shapes(path):
    lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
    sec = '?'
    out = {}
    for i, l in enumerate(lines):
        if l.startswith('|uhdm') and l.endswith(':'):
            sec = l.strip('|:')
        m = PAS.match(l)
        if not m:
            continue
        base = len(m.group(1))
        lhs = ''
        shape = ''
        j = i + 1
        while j < len(lines):
            s = lines[j]
            if s.strip() and (len(s) - len(s.lstrip())) <= base:
                break
            ind = len(s) - len(s.lstrip())
            if s.strip() == '|vpiLhs:' and ind == base + 2:
                k = PAR.match(lines[j + 1] if j + 1 < len(lines) else '')
                if k:
                    lhs = k.group(1)
            if s.strip() == '|vpiRhs:' and ind == base + 2 and not shape:
                k = OBJ.match(lines[j + 1] if j + 1 < len(lines) else '')
                if k:
                    oi = len(k.group(1))
                    kids = []
                    for t in range(j + 2, len(lines)):
                        ts = lines[t]
                        if not ts.strip():
                            continue
                        ti = len(ts) - len(ts.lstrip())
                        if ti <= oi:
                            break
                        ck = OBJ.match(ts)
                        if ck and ti == oi + 2:
                            kids.append(ck.group(2))
                    shape = k.group(2) + '(' + ','.join(kids) + ')'
            j += 1
        if lhs:
            out.setdefault((sec, lhs), []).append(shape)
    return out


g, o = shapes(sys.argv[1]), shapes(sys.argv[2])
bad = 0
for key in sorted(set(g) | set(o)):
    gs, os_ = g.get(key, []), o.get(key, [])
    mark = '   ' if gs == os_ else '<<<'
    if gs != os_:
        bad += 1
    print('%s %-16s %-40s GOLD=%-46s OURS=%s'
          % (mark, key[0], key[1], '|'.join(gs), '|'.join(os_)))
print('SHAPE-DIFFERING param_assign KEYS: %d' % bad)
