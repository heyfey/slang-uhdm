#!/usr/bin/env python3
"""vrgg1 cell reader — for BOTH param_assign and cont_assign objects, key by the
Lhs NAME and print the Rhs shape, then diff golden against ours side by side.

  usage: vcell_rgg1.py <g.dump> <o.dump> [--view=def|top|both] [--kind=both|ca|pa]

GUARD: a side that yields ZERO rows is printed as EMPTY and makes the script
exit non-zero — a reader that read nothing must never look like agreement.
Locations ARE printed (loc-less vs located is the whole point of these laws)
but the workdir is never in a dump line we read.
"""
import re, sys, collections

VAL = re.compile(r'^\|((?:BIN|HEX|OCT|DEC|INT|UINT|STRING|REAL|SCAL):\S*)\s*$')

def indent(l):
    return len(l) - len(l.lstrip(' '))

def children(lines, i, hi):
    d = indent(lines[i]); j = i + 1; out = []
    while j < hi:
        if not lines[j].strip():
            j += 1; continue
        if indent(lines[j]) <= d:
            break
        if indent(lines[j]) == d + 2:
            out.append(j)
        j += 1
    return out, j

def objname(l):
    m = re.search(r'\\_(\w+):\s*(?:(\S+)\s*)?\(([^)]*)\)', l)
    if m:
        return m.group(1), (m.group(2) or ''), m.group(3)
    m = re.search(r'\\_(\w+):', l)
    return (m.group(1) if m else '?'), '', ''

def loc_of(line):
    m = re.search(r'\((\d+:\d+-\d+:\d+)\)', line)
    return m.group(1) if m else 'NOLOC'

def describe(lines, i, hi):
    kind, nm, _ = objname(lines[i])
    loc = loc_of(lines[i])
    if kind != 'constant':
        return '%-12s %-22s loc=%s' % ('<' + kind + '>', nm, loc)
    kids, _ = children(lines, i, hi)
    ct = val = sz = dc = None
    for k in kids:
        t = lines[k].strip()
        m = VAL.match(t)
        if m: val = m.group(1)
        elif t.startswith('|vpiConstType:'): ct = t.split(':', 1)[1]
        elif t.startswith('|vpiSize:'): sz = t.split(':', 1)[1]
        elif t.startswith('|vpiDecompile:'): dc = t.split(':', 1)[1]
    return "const ct=%-2s %-14s sz=%-4s dec=%-10s loc=%s" % (
        ct or '?', val or '?', sz or '?', dc if dc is not None else '', loc)

def lhs_key(lines, i, hi):
    kind, nm, _ = objname(lines[i])
    if kind == 'hier_path':
        return nm or '<hp>'
    return nm or ('<' + kind + '>')

def scan(lines, lo, hi, kinds):
    rows = []
    i = lo
    while i < hi:
        obj = None
        if 'ca' in kinds and '\\_cont_assign:' in lines[i]: obj = 'CA'
        elif 'pa' in kinds and '\\_param_assign:' in lines[i]: obj = 'PA'
        if not obj:
            i += 1; continue
        kids, nxt = children(lines, i, hi)
        name = rhs = None
        for idx, k in enumerate(kids):
            t = lines[k].strip()
            if t == '|vpiLhs:' and idx + 1 < len(kids):
                name = lhs_key(lines, kids[idx + 1], hi)
            elif t == '|vpiRhs:' and idx + 1 < len(kids):
                rhs = describe(lines, kids[idx + 1], hi)
        if name:
            rows.append((obj + ' ' + name.split('::')[-1], rhs or '<none>'))
        i = nxt
    return rows

def load(path, view, kinds):
    with open(path, errors='replace') as f:
        lines = f.read().splitlines()
    fence = next((i for i, l in enumerate(lines) if l.startswith('|uhdmtopModules:')), len(lines))
    lo, hi = 0, len(lines)
    if view == 'def': hi = fence
    elif view == 'top': lo = fence
    seen = collections.OrderedDict()
    for nm, r in scan(lines, lo, hi, kinds):
        seen.setdefault(nm, r)
    return seen

def main():
    g, o = sys.argv[1], sys.argv[2]
    view, kinds = 'both', 'ca,pa'
    for a in sys.argv[3:]:
        if a.startswith('--view='): view = a.split('=', 1)[1]
        elif a.startswith('--kind='):
            k = a.split('=', 1)[1]
            kinds = 'ca,pa' if k == 'both' else k
    G = load(g, view, kinds); O = load(o, view, kinds)
    if not G:
        print('GOLDEN EMPTY')
    if not O: print('OURS EMPTY')
    keys = list(G.keys()) + [k for k in O.keys() if k not in G]
    nsame = ndiff = 0
    for k in keys:
        gv, ov = G.get(k, '<ABSENT>'), O.get(k, '<ABSENT>')
        tag = 'ok  ' if gv == ov else 'DIFF'
        if gv == ov: nsame += 1
        else: ndiff += 1
        print('%s %-26s G: %s' % (tag, k, gv))
        if gv != ov:
            print('%s %-26s O: %s' % ('    ', '', ov))
    print('CELLS same=%d diff=%d (view=%s kinds=%s)' % (nsame, ndiff, view, kinds))
    sys.exit(0 if (G and O) else 3)

main()
