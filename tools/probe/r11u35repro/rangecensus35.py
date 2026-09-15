#!/usr/bin/env python3
"""r11u35 — THE RANGE-BOUND CENSUS, KEYED ON THE **VIEW**  (+ its SHAPE LISTER).

Why a new one.  `tools/probe/r11u33repro/rangecensus33.py` answers the
ENCODING question and is BLIND to this pass's: it lists `vpiTypedef` in its
`BACK` set, so the DEFINITION module's own typedef list — the very site where
`CompileModule.cpp:653`'s `Reduce::No` shows — is never walked, and its `view`
column collapses every section onto the last one seen.  A census that cannot
see the def view cannot measure a def-vs-elab law.  Calibrate golden-vs-golden
first; a census that reaches nothing must never read as perfection, so a
section with zero range bounds is PRINTED with its zero.

One row per RANGE BOUND:

    <view> <holder-chain> <range-loc> <side> <shape+enc> <bound-loc> xN

  view          the design-level section the object hangs under, verbatim
                (uhdmallModules / uhdmtopModules / uhdmallPackages /
                uhdmtopPackages / uhdmallInterfaces / uhdmtopInterfaces / ...),
                joined with the OWNING instance's name so the DEF copy of a
                module and its ELAB copy are never the same cell
  holder-chain  ancestor kinds (with names where the dump prints them),
                nearest-first, at most four deep
  side          L | R
  shape+enc     constant -> `const <TAG>:<v>@<size>ct<ct>`
                operation -> `op<type>(<operand kinds>)`
                ref_obj / hier_path -> the kind and the printed name
                so a "kept the operation" difference and a "size" difference
                can never be confused

LHS IS ALWAYS GOLDEN: this reads ONE dump; the caller pairs two runs.
"""
import re
import sys
from collections import Counter

OPEN = re.compile(r'^(\s*)\\_([a-z_]+):\s*(.*)$')
FIELD = re.compile(r'^(\s*)\|([A-Za-z_]+):?(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)')

# Back-edges: a child reached through one of these is a REFERENCE to an object
# owned elsewhere, and walking it double-counts.  `vpiTypedef` is deliberately
# NOT here — on a module_inst / package / interface_inst it is the OWNING
# typedef list (the def view's whole surface); on a port / net it is a
# ref_typespec back-edge, and OWNERS below draws that line.
BACK = {'vpiParent', 'vpiActual', 'vpiInstance', 'vpiClassDefn',
        'vpiLowConn', 'vpiHighConn', 'vpiExpr', 'vpiFunction', 'vpiTask'}
# The kinds whose `vpiTypedef` is an owning list rather than a back-edge.
OWNERS = {'module_inst', 'package', 'interface_inst', 'program', 'class_defn',
          'gen_scope', 'gen_scope_array', 'function', 'task', 'begin',
          'named_begin'}


class Node:
    __slots__ = ('kind', 'head', 'field', 'parent', 'kids', 'attrs', 'loc',
                 'name')

    def __init__(self, kind, head, field, parent):
        self.kind = kind
        self.head = head
        self.field = field
        self.parent = parent
        self.kids = []
        self.attrs = {}
        m = LOC.search(head or '')
        self.loc = '%s:%s' % (m.group(1), m.group(2)) if m else '-'
        # SPACE-FREE by construction: a module_inst head prints
        # `work@x (work@x), file:...` and the census columns are
        # whitespace-split by the pairing tool.
        self.name = (head.split(',')[0].strip().split(' ')[0]
                     if head else '')


def parse(path):
    root = Node('design', '', '', None)
    stack = [(-1, root)]
    pending = {}
    for raw in open(path, encoding='utf-8', errors='replace'):
        line = raw.rstrip('\n')
        m = OPEN.match(line)
        if m:
            ind = len(m.group(1))
            while len(stack) > 1 and stack[-1][0] >= ind:
                stack.pop()
            # A field line labels exactly ONE following object — the dump
            # re-prints `|vpiRange:` / `|vpiTypedef:` before every element of a
            # list — so the label is CONSUMED here.  Without that, the
            # `weaklyReferenced` pool (whose entries open at indent 0 with no
            # field of their own) inherits `uhdmtopModules` and a pool cell is
            # mistaken for an elaborated one.
            n = Node(m.group(2), m.group(3), pending.pop(ind, ''), stack[-1][1])
            stack[-1][1].kids.append(n)
            stack.append((ind, n))
            continue
        m = FIELD.match(line)
        if m:
            ind = len(m.group(1))
            name, val = m.group(2), m.group(3)
            while len(stack) > 1 and stack[-1][0] >= ind:
                stack.pop()
            pending[ind] = name
            if val != '':
                stack[-1][1].attrs.setdefault(name, []).append(val)
    return root


def enc(n):
    if n.kind == 'constant':
        a = n.attrs
        tag = '?'
        for k in ('UINT', 'INT', 'BIN', 'HEX', 'OCT', 'DEC', 'REAL', 'STRING',
                  'SCAL'):
            if k in a:
                tag = '%s:%s' % (k, a[k][0])
                break
        return 'const %s@%s ct%s' % (tag, a.get('vpiSize', ['-'])[0],
                                     a.get('vpiConstType', ['-'])[0])
    if n.kind == 'operation':
        ops = [k.kind for k in n.kids if k.field == 'vpiOperand']
        return 'op%s(%s)' % (n.attrs.get('vpiOpType', ['?'])[0], ','.join(ops))
    if n.kind in ('ref_obj', 'hier_path'):
        # `VpiName` is what the judge reads; the parenthesised head the dump
        # prints is the SYNTHESISED VpiFullName, which no generated Compare
        # reads (RESUME.md §9).  Print the judged field, and fall back to the
        # head only when the dump printed no name at all.
        return '%s %s' % (n.kind, n.attrs.get('vpiName', [n.name])[0])
    return n.kind


def chain(n, top):
    out = []
    p = n.parent
    while p is not None and p is not top.parent and len(out) < 4:
        out.append('%s%s' % (p.kind, p.name if p.name else ''))
        p = p.parent
    return '/'.join(out) if out else '-'


def walk(n, view, top, rows, seen):
    if n.kind == 'range' and id(n) not in seen:
        seen.add(id(n))
        for side, fld in (('L', 'vpiLeftRange'), ('R', 'vpiRightRange')):
            k = [c for c in n.kids if c.field == fld]
            rows.append((view, chain(n, top), n.loc, side,
                         enc(k[0]) if k else '<none>',
                         k[0].loc if k else '-'))
    for c in n.kids:
        if c.field in BACK:
            continue
        if c.field == 'vpiTypedef' and n.kind not in OWNERS:
            continue
        walk(c, view, top, rows, seen)


def main():
    root = parse(sys.argv[1])
    rows = []
    seen = set()
    empty = []
    for c in root.kids:
        view = '%s|%s' % (c.field or 'pool', c.name or '-')
        before = len(rows)
        walk(c, view, c, rows, seen)
        if len(rows) == before:
            empty.append(view)
    cnt = Counter(rows)
    for r, c in sorted(cnt.items()):
        print('%-46s %-46s %-9s %s %-34s %-9s x%d' %
              (r[0], r[1], r[2], r[3], r[4], r[5], c))
    for v in empty:
        # A section the walk reached and found EMPTY is printed with its zero:
        # a census that reaches nothing must never read as perfection.
        print('%-46s %-46s %-9s %s %-34s %-9s x0' % (v, '<no-range-bound>',
                                                     '-', '-', '-', '-'))
    print('-- ranges=%d rows=%d sections=%d empty=%d' %
          (len(seen), sum(cnt.values()), len(root.kids), len(empty)))


if __name__ == '__main__':
    main()
