#!/usr/bin/env python3
"""r11u32 — read the golden grid: per arm signal, the DEF-view vpiNetType and
the ELAB-view object KIND, from a uhdm-dump.

DUMP SHAPE (measured, not assumed — see /tmp dump excerpt in the README):
an object header sits at indent I and its OWN fields at indent I+2; a child
object that is the value of one of those fields also sits at I+2 with its own
fields at I+4.  So `|vpiNetType:` at indent I+2 belongs to the header at I.
Reading "the next |vpiNetType: after the header" instead silently mis-attributes
(it was reading past child objects) — the first version of this reader did and
printed a grid with the wrong DEF column.

Sections exactly as the kind census does:
   DEF  = |uhdmallModules: .. |uhdmtopModules:
   ELAB = |uhdmtopModules: .. \\_weaklyReferenced:      (TAIL never read)
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\?_?([a-z_0-9]+): \(([^)]*)\)')
FLD = re.compile(r'^(\s*)\|([A-Za-z]+):(.*)$')

def sections(path):
    lines = open(path, errors='replace').read().split('\n')
    d = e = t = None
    for i, l in enumerate(lines):
        s = l.strip()
        if s == '|uhdmallModules:' and d is None: d = i
        elif s == '|uhdmtopModules:' and e is None: e = i
        elif s.startswith('\\_weaklyReferenced:') and t is None: t = i
    n = len(lines)
    return lines[(d or 0):(e or n)], lines[(e or n):(t or n)]

def scan(lines, want):
    """-> {leaf: (kind, nettype)} for the OUTERMOST sighting of each wanted leaf."""
    out, stack = {}, []   # stack of (indent, leaf-or-None, kind)
    for l in lines:
        m = OBJ.match(l)
        if m:
            ind = len(m.group(1))
            kind, fn = m.group(2), m.group(3)
            leaf = fn.split('.')[-1] if fn else ''
            while stack and stack[-1][0] >= ind:
                stack.pop()
            stack.append((ind, leaf if want(leaf) else None, kind))
            if want(leaf) and leaf not in out:
                out[leaf] = [kind, None]
            continue
        m2 = FLD.match(l)
        if not m2:
            continue
        ind, field, val = len(m2.group(1)), m2.group(2), m2.group(3)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        if field == 'vpiNetType' and stack and stack[-1][1]:
            leaf = stack[-1][1]
            if out[leaf][1] is None and out[leaf][0] == stack[-1][2]:
                out[leaf][1] = val.strip()
    return {k: tuple(v) for k, v in out.items()}

def main():
    g, o = sys.argv[1], sys.argv[2]
    want = lambda leaf: leaf.startswith('x_')
    gd, ge = sections(g); od, oe = sections(o)
    GD, GE, OD, OE = scan(gd, want), scan(ge, want), scan(od, want), scan(oe, want)
    names = sorted(set(GD) | set(OD) | set(GE) | set(OE))
    print(f'{"ARM":22s} | {"DEF golden":22s} | {"DEF ours":22s} | {"ELAB golden":18s} | {"ELAB ours":18s} | VERDICT')
    nd = ne = 0
    for n in names:
        a = GD.get(n, ('-', None)); b = OD.get(n, ('-', None))
        c = GE.get(n, ('-', None)); d = OE.get(n, ('-', None))
        fa = f'{a[0]} nt={a[1] or "-"}'; fb = f'{b[0]} nt={b[1] or "-"}'
        vd = '' if a == b else 'DEF-DIFF'
        ve = '' if c[0] == d[0] else 'ELAB-DIFF'
        nd += bool(vd); ne += bool(ve)
        print(f'{n:22s} | {fa:22s} | {fb:22s} | {c[0]:18s} | {d[0]:18s} | {vd} {ve}')
    print(f'-- arms: {len(names)}   DEF-DIFF: {nd}   ELAB-DIFF: {ne}')

main()
