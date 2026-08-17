#!/usr/bin/env python3
"""r10earl52 census — every param_assign Rhs CONSTANT in a dump, keyed by the
Lhs parameter's FULL name plus the constant's source span, valued by the four
encoding fields this pass can move.

Order-blind and workdir-blind: the key carries no object identity and no file
path, so a golden dump and one of ours can be joined even though their object
order differs.  This is the instrument the CENSUS_PREDICT is written from and
the one the post-run attribution reads.

  usage: census52.py <dump> [--view=def|top|both]
"""
import re, sys, collections

VAL = re.compile(r'^\|((?:BIN|HEX|OCT|DEC|INT|UINT|STRING|REAL|SCAL):\S*)\s*$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def indent(l):
    return len(l) - len(l.lstrip(' '))


def kids(lines, i, hi):
    d = indent(lines[i])
    j, out = i + 1, []
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
    m = re.search(r'\\_(\w+):\s*(?:\S+\s*)?\(([^)]*)\)', l)
    return (re.search(r'\\_(\w+):', l).group(1) if '\\_' in l else '?',
            m.group(2) if m else '')


def main():
    path = sys.argv[1]
    view = 'both'
    for a in sys.argv[2:]:
        if a.startswith('--view='):
            view = a.split('=', 1)[1]
    with open(path, errors='replace') as f:
        lines = f.read().splitlines()
    fence = next((i for i, l in enumerate(lines)
                  if l.startswith('|uhdmtopModules:')), len(lines))
    lo, hi = (0, len(lines))
    if view == 'def':
        hi = fence
    elif view == 'top':
        lo = fence
    rows = collections.Counter()
    i = lo
    while i < hi:
        if '\\_param_assign:' not in lines[i]:
            i += 1
            continue
        ks, nxt = kids(lines, i, hi)
        name, ci = None, None
        for idx, k in enumerate(ks):
            t = lines[k].strip()
            if t == '|vpiLhs:' and idx + 1 < len(ks):
                name = objname(lines[ks[idx + 1]])[1]
            elif t == '|vpiRhs:' and idx + 1 < len(ks):
                if objname(lines[ks[idx + 1]])[0] == 'constant':
                    ci = ks[idx + 1]
        if name and ci is not None:
            ck, _ = kids(lines, ci, hi)
            ct = val = sz = dc = ''
            for k in ck:
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
            sp = SPAN.search(lines[ci])
            span = ':'.join(sp.groups()) if sp else '?'
            rows[(name, span, ct, val, sz, dc)] += 1
        i = nxt
    for k in sorted(rows):
        print("%d\t%s" % (rows[k], '\t'.join(k)))


main()
