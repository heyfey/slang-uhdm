#!/usr/bin/env python3
"""r10rgg6/dumpscan.py -- read a uhdm-dump text and report, per VIEW, every
param-initializer func_call and whether it carries a vpiTypespec.

The dump is an indentation tree: a line `\\_kind: (name), line:L:C` opens an
object at its indentation, `|field:` lines name the edge the NEXT object hangs
off, and scalar fields print as `|name:value`.

Output is one TSV row per func_call that is (transitively) a param_assign Rhs:

  view  instpath  lhs  fnname  line:col  TS  tsactual

  view      DEF (uhdmallModules) | ELAB (uhdmtopModules) | OTHER
  TS        the func_call's own vpiTypespec: 'none' or 'ts'
  tsactual  the vpiActual of that ref_typespec, as kind@line:col
"""
import re, sys, collections

OPEN = re.compile(r'^(\s*)\\_([A-Za-z_]+): ?(.*)$')
FIELD = re.compile(r'^(\s*)\|([A-Za-z_]+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)')


class Node:
    __slots__ = ('kind', 'rest', 'ind', 'children', 'scalars', 'parent', 'edge')
    def __init__(self, kind, rest, ind):
        self.kind, self.rest, self.ind = kind, rest, ind
        self.children = []      # (edge, Node)
        self.scalars = {}
        self.parent = None
        self.edge = None
    @property
    def name(self):
        m = re.search(r'\(([^)]*)\)', self.rest)
        return m.group(1) if m else ''
    @property
    def loc(self):
        m = LOC.search(self.rest)
        return '%s:%s' % (m.group(1), m.group(2)) if m else '?'


def parse(path):
    root = Node('ROOT', '', -1)
    stack = [root]
    pending = None          # edge name for the next opened object
    seen = {}
    with open(path, 'rt', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n')
            m = OPEN.match(line)
            if m:
                ind = len(m.group(1))
                n = Node(m.group(2), m.group(3), ind)
                while stack and stack[-1].ind >= ind:
                    stack.pop()
                if not stack:
                    stack = [root]
                n.parent = stack[-1]
                n.edge = pending
                stack[-1].children.append((pending, n))
                stack.append(n)
                pending = None
                continue
            m = FIELD.match(line)
            if m:
                ind, key, val = len(m.group(1)), m.group(2), m.group(3)
                while stack and stack[-1].ind >= ind:
                    stack.pop()
                if not stack:
                    stack = [root]
                if val == '':
                    pending = key
                else:
                    stack[-1].scalars[key] = val
                continue
    return root


def view_of(n):
    while n is not None:
        if n.edge == 'uhdmallModules':
            return 'DEF'
        if n.edge == 'uhdmtopModules':
            return 'ELAB'
        n = n.parent
    return 'OTHER'


def instpath(n):
    """nearest enclosing module_inst's INSTANCE name (the paren name)."""
    while n is not None:
        if n.kind in ('module_inst', 'package', 'gen_scope'):
            return n.name
        n = n.parent
    return '?'


def walk(n, out):
    for edge, c in n.children:
        # a func_call whose PARENT edge is vpiRhs of a param_assign
        if c.kind == 'func_call' and edge == 'vpiRhs' and n.kind == 'param_assign':
            lhs = ''
            for e2, c2 in n.children:
                if e2 == 'vpiLhs':
                    lhs = c2.name.split('.')[-1]
            ts, tsact = 'none', '-'
            for e2, c2 in c.children:
                if e2 == 'vpiTypespec' and c2.kind == 'ref_typespec':
                    ts = 'ts'
                    for e3, c3 in c2.children:
                        if e3 == 'vpiActual':
                            tsact = '%s@%s' % (c3.kind, c3.loc)
            # what the ARGUMENT reduced to
            args = [c2.kind for e2, c2 in c.children if e2 == 'vpiArgument']
            out.append((view_of(c), instpath(c), lhs, c.name, c.loc, ts, tsact,
                        ','.join(args)))
        walk(c, out)


def paramts(n, out):
    """every `parameter` object's OWN ref_typespec actual (the DEF-view rebind
    probe): view, instpath, param name, actual kind@loc."""
    for edge, c in n.children:
        if c.kind == 'parameter':
            act = '-'
            for e2, c2 in c.children:
                if e2 == 'vpiTypespec' and c2.kind == 'ref_typespec':
                    for e3, c3 in c2.children:
                        if e3 == 'vpiActual':
                            act = '%s@%s' % (c3.kind, c3.loc)
            out.append((view_of(c), instpath(c), c.name.split('.')[-1], act))
        paramts(c, out)


def allcalls(n, out, path):
    """EVERY func_call in the database, keyed the way a census must be:
    view + enclosing instance/scope path + name + line:col, plus the
    vpiTypespec verdict.  Nothing here reads fullname or span."""
    for edge, c in n.children:
        p2 = path
        if c.kind in ('module_inst', 'package', 'gen_scope', 'interface_inst'):
            p2 = c.name
        if c.kind == 'func_call':
            ts, tsact = 'none', '-'
            for e2, c2 in c.children:
                if e2 == 'vpiTypespec' and c2.kind == 'ref_typespec':
                    ts = 'ts'
                    for e3, c3 in c2.children:
                        if e3 == 'vpiActual':
                            tsact = '%s@%s' % (c3.kind, c3.loc)
            out.append((view_of(c), p2, c.name, c.loc, ts, tsact))
        allcalls(c, out, p2)


if __name__ == '__main__':
    root = parse(sys.argv[1])
    what = sys.argv[2] if len(sys.argv) > 2 else 'calls'
    rows = []
    if what == 'calls':
        walk(root, rows)
    elif what == 'allcalls':
        allcalls(root, rows, '?')
    else:
        paramts(root, rows)
    for r in rows:
        print('\t'.join(r))
