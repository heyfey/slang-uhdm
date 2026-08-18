#!/usr/bin/env python3
# r10uvm99 — MEASUREMENT ONLY.  The INSIDE/LIST-OP census, read off a
# `uhdm-dump` text tree (the dump is exactly the REACHABLE tree, so no row can
# name an object the judge cannot see — uvm97's AllObjects trap).
#
#   row = SITE \t KEY \t VALUE
#   SITE  INSIDE   an operation with vpiOpType 95 (vpiInsideOp)
#         LISTOP   an operation with vpiOpType 37 (vpiListOp)
#   KEY   <nearest named ancestor>@<span of the operation>   (never the file,
#         never the source text)
#   VALUE n=<operand count>|<per-operand kind(name)@span, op-kind for nested
#         operations with their own operands in {}>
#
# LHS is ALWAYS golden.
import sys, re, os, collections

NODE  = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?, line:(\d+):(\d+), endln:(\d+):(\d+)')
NODE2 = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?\s*$')
FIELD = re.compile(r'^(\s*)\|(\w+):(.*)$')

class N:
    __slots__ = ('kind', 'name', 'span', 'fields', 'indent', 'parent')
    def __init__(s, kind, name, span, indent):
        s.kind = kind; s.name = name; s.span = span
        s.fields = {}; s.indent = indent; s.parent = None

def parse(path):
    roots = []; stack = []
    for line in open(path, 'rt', errors='replace'):
        line = line.rstrip('\n')
        m = NODE.match(line); m2 = None if m else NODE2.match(line)
        if m or m2:
            g = m or m2
            ind = len(g.group(1))
            span = ((int(m.group(4)), int(m.group(5)), int(m.group(6)), int(m.group(7)))
                    if m else (0, 0, 0, 0))
            n = N(g.group(2), g.group(3) or '', span, ind)
            while stack and stack[-1][0] >= ind: stack.pop()
            if stack:
                n.parent = stack[-1][1]
                stack[-1][1].fields.setdefault(stack[-1][2] or '?', []).append(n)
            else:
                roots.append(n)
            stack.append([ind, n, None])
            continue
        f = FIELD.match(line)
        if f:
            ind = len(f.group(1))
            while stack and stack[-1][0] >= ind: stack.pop()
            if not stack: continue
            stack[-1][2] = f.group(2)
            if f.group(3) != '':
                stack[-1][1].fields.setdefault(f.group(2), []).append(f.group(3))
    return roots

def walk(n, out):
    out.append(n)
    for k, v in n.fields.items():
        if k == 'vpiParent': continue
        for c in v:
            if isinstance(c, N) and c.parent is n: walk(c, out)

def sp(n): return '%d:%d-%d:%d' % n.span

def opty(n):
    for x in n.fields.get('vpiOpType', []):
        if isinstance(x, str): return x
    return '-'

def nm(n):
    if n.name: return n.name
    for x in n.fields.get('vpiName', []):
        if isinstance(x, str): return x
    return ''

def desc(n, depth=0):
    if n.kind == 'operation':
        sub = [x for x in n.fields.get('vpiOperand', []) if isinstance(x, N)]
        inner = '|'.join(desc(x, depth + 1) for x in sub) if depth < 2 else '...'
        return 'op%s@%s{%s}' % (opty(n), sp(n), inner)
    return '%s(%s)@%s' % (n.kind, nm(n), sp(n))

def scope(n):
    p = n.parent
    while p is not None:
        s = nm(p)
        if s: return s
        p = p.parent
    return '-'

def main():
    roots = parse(sys.argv[1])
    alln = []
    for r in roots: walk(r, alln)
    want = set((os.environ.get('OPS99') or '95,37').split(','))
    rows = []
    for n in alln:
        if n.kind != 'operation': continue
        t = opty(n)
        if t not in want: continue
        site = 'INSIDE' if t == '95' else 'LISTOP'
        ops = [o for o in n.fields.get('vpiOperand', []) if isinstance(o, N)]
        rows.append('%s\t%s@%s\tn=%d|%s' % (
            site, scope(n), sp(n), len(ops), ' , '.join(desc(o) for o in ops)))
    rows.sort()
    for r in rows: print(r)

main()
