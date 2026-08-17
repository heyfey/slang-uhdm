#!/usr/bin/env python3
"""r10earl52 — per-param_assign Rhs reader, keyed by the Lhs parameter NAME.

The dump is indentation-structured (`\\_` prefixes an object, `|field:` a
field, both at the owner's indent + 2).  For every `param_assign` OBJECT we
read its direct `|vpiLhs:` child's name and its direct `|vpiRhs:` child's
shape; for a constant Rhs we print {vpiConstType, VALUE, vpiSize,
vpiDecompile} — the dump prints the value as a bare `|BIN:1` / `|INT:-1` /
`|UINT:5` / `|STRING:x` / `|REAL:1.0` line, NOT as `vpiValue`.

Back-references (a child's `|vpiParent:` printing another `param_assign:`
line) are skipped because only DIRECT children of the block are read.

  usage: grid52.py <dump> [--view=def|top|both] [--only=PREFIX]
"""
import re, sys, collections

VAL = re.compile(r'^\|((?:BIN|HEX|OCT|DEC|INT|UINT|STRING|REAL|SCAL):\S*)\s*$')


def indent(l):
    return len(l) - len(l.lstrip(' '))


def children(lines, i, hi):
    """Yield (field_or_obj_line_index) for the DIRECT children of the object
    that starts at line i."""
    d = indent(lines[i])
    j = i + 1
    out = []
    while j < hi:
        if not lines[j].strip():
            j += 1
            continue
        if indent(lines[j]) <= d:
            break
        if indent(lines[j]) == d + 2:
            out.append(j)
        j += 1
    return out, j


def objname(l):
    m = re.search(r'\\_(\w+):\s*(?:(\S+)\s*)?\(([^)]*)\)', l)
    if m:
        return m.group(1), m.group(3)
    m = re.search(r'\\_(\w+):', l)
    return (m.group(1) if m else '?'), ''


def describe(lines, i, hi):
    kind, _ = objname(lines[i])
    if kind != 'constant':
        return '<%s>' % kind
    kids, _ = children(lines, i, hi)
    ct = val = sz = dc = None
    for k in kids:
        t = lines[k].strip()
        m = VAL.match(t)
        if m:
            val = m.group(1)
        elif t.startswith('|vpiConstType:'):
            ct = t.split(':', 1)[1]
        elif t.startswith('|vpiSize:'):
            sz = t.split(':', 1)[1]
        elif t.startswith('|vpiDecompile:'):
            dc = t.split(':', 1)[1]
    return "ct=%-2s %-16s sz=%-3s dec=%s" % (ct or '?', val or '?', sz or '?',
                                             dc if dc is not None else '')


def scan(lines, lo, hi, only):
    rows = []
    i = lo
    while i < hi:
        if '\\_param_assign:' not in lines[i]:
            i += 1
            continue
        kids, nxt = children(lines, i, hi)
        name = None
        rhs = None
        for idx, k in enumerate(kids):
            t = lines[k].strip()
            if t == '|vpiLhs:' and idx + 1 < len(kids):
                _, nm = objname(lines[kids[idx + 1]])
                name = nm.split('.')[-1].split('::')[-1]
            elif t == '|vpiRhs:' and idx + 1 < len(kids):
                rhs = describe(lines, kids[idx + 1], hi)
        if name and (not only or name.startswith(only)):
            rows.append((name, rhs or '<none>'))
        i = nxt
    return rows


def main():
    path = sys.argv[1]
    view = 'both'
    only = ''
    for a in sys.argv[2:]:
        if a.startswith('--view='):
            view = a.split('=', 1)[1]
        elif a.startswith('--only='):
            only = a.split('=', 1)[1]
    with open(path, errors='replace') as f:
        lines = f.read().splitlines()
    fence = next((i for i, l in enumerate(lines) if l.startswith('|uhdmtopModules:')),
                 len(lines))
    lo, hi = (0, len(lines))
    if view == 'def':
        hi = fence
    elif view == 'top':
        lo = fence
    seen = collections.OrderedDict()
    for nm, r in scan(lines, lo, hi, only):
        seen.setdefault(nm, r)
    for nm, r in seen.items():
        print("%-12s | %s" % (nm, r))


main()
