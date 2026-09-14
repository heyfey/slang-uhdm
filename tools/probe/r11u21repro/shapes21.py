#!/usr/bin/env python3
"""r11u21 SHAPE LISTER — the OPERAND TREE of every elaborated `param_assign`
Rhs, beside the keyed census (the census keys on judge-visible CELLS; a shape
change that keeps every cell would be invisible to it, and a cell change that
came from a different TREE would be attributed wrong).

    shapes21.py <dump> [<dump2>]      one column, or two side by side
Each line is `<section> <Lhs fullname>  <shape>` where the shape is the Rhs
object kind followed by its operand kinds, parenthesised, to depth 3.
"""
import re, sys

SECT = re.compile(r'^\|uhdm(\w+):')
KIND = re.compile(r'^(\s*)\\_(\w+):')

def shapes(path):
    lines = open(path, errors='replace').read().split('\n')
    out = {}
    sect = '?'
    def ind(s):
        return len(s) - len(s.lstrip(' '))
    i, n = 0, len(lines)
    while i < n:
        m = SECT.match(lines[i])
        if m:
            sect = m.group(1); i += 1; continue
        if re.match(r'^\s*\\_param_assign: ', lines[i]):
            base = ind(lines[i]); j = i + 1
            blk = []
            while j < n and (lines[j].strip() == '' or ind(lines[j]) > base):
                blk.append(lines[j]); j += 1
            lhs = None
            sh = '<none>'
            for k, l in enumerate(blk):
                if l.strip() == '|vpiLhs:' and ind(l) == base + 2 and k + 1 < len(blk):
                    mm = re.match(r'\s*\\_\w+: \(([^)]*)\)', blk[k + 1])
                    if mm: lhs = mm.group(1)
                if l.strip() == '|vpiRhs:' and ind(l) == base + 2 and k + 1 < len(blk):
                    sh = tree(blk, k + 1, 0)
            if lhs:
                out[(sect, lhs)] = sh
            i = j; continue
        i += 1
    return out

def tree(blk, k, depth):
    def ind(s):
        return len(s) - len(s.lstrip(' '))
    m = KIND.match(blk[k])
    if not m:
        return '?'
    kind = m.group(2)
    if depth >= 3:
        return kind
    rb = ind(blk[k])
    kids = []
    q = k + 1
    while q < len(blk) and (blk[q].strip() == '' or ind(blk[q]) > rb):
        t = blk[q].strip()
        if ind(blk[q]) == rb + 2 and t in ('|vpiOperand:', '|vpiActual:',
                                           '|vpiIndex:', '|vpiExpr:'):
            if q + 1 < len(blk):
                kids.append(tree(blk, q + 1, depth + 1))
        q += 1
    return kind + ('(' + ','.join(kids) + ')' if kids else '')

a = shapes(sys.argv[1])
b = shapes(sys.argv[2]) if len(sys.argv) > 2 else None
for k in sorted(set(a) | (set(b) if b else set())):
    if b is None:
        print('%-13s %-46s %s' % (k[0], k[1], a.get(k, '<absent>')))
    else:
        sa, sb = a.get(k, '<absent>'), b.get(k, '<absent>')
        print('%-4s %-13s %-46s %s | %s'
              % ('SAME' if sa == sb else 'SHAPE', k[0], k[1], sa, sb))
