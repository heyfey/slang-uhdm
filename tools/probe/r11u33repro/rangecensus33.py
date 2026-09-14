#!/usr/bin/env python3
"""r11u33 — THE RANGE-BOUND CENSUS (and its SHAPE LISTER).

Reads a `uhdm-dump` listing and reports ONE ROW PER RANGE BOUND:

    <view> <holder-chain> <range-loc> <side> <shape> <enc>

where
  view          the top-level section the object hangs under
                (allModules / topModules / allPackages / topPackages / pool)
  holder-chain  the ancestor kinds (and names where the dump prints them),
                nearest-first, up to the section — THIS is the "holder" axis
                the triage asked for, read out of the dump's own nesting and
                never guessed
  side          L | R   (vpiLeftRange / vpiRightRange, or Left_expr/Right_expr
                as the dump spells them)
  shape         the bound object's kind: constant / operation / ref_obj /
                hier_path / sys_func_call / ...
  enc           for a constant: `<TAG>:<value>@<size>ct<constType>`
                for an operation: `op<type>(<operand kinds>)`
                otherwise the kind alone

LHS IS ALWAYS GOLDEN: this tool reads ONE dump; the caller pairs two runs.

The dump is an INDENTED tree — two spaces per level, `\\_<kind>` opening an
object and `|<field>` naming a field of the object that owns it.  The parser
tracks the field a child was reached through, so a range's left and right
bounds are never confused with each other, and a constant under an operation
under a range is reported once, under the operation.
"""
import re
import sys

OPEN = re.compile(r'^(\s*)\\_([a-z_]+):\s*(.*)$')
FIELD = re.compile(r'^(\s*)\|([A-Za-z_]+):?(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)')


class Node:
    __slots__ = ('kind', 'head', 'field', 'parent', 'kids', 'attrs', 'loc')

    def __init__(self, kind, head, field, parent):
        self.kind = kind
        self.head = head
        self.field = field
        self.parent = parent
        self.kids = []
        self.attrs = {}
        m = LOC.search(head or '')
        self.loc = '%s:%s' % (m.group(1), m.group(2)) if m else '-'


def parse(path):
    root = Node('design', '', '', None)
    # stack of (indent, node); a field line sets pending_field for the NEXT open
    stack = [(-1, root)]
    pending = {}   # indent -> field name most recently seen at that indent
    for raw in open(path, encoding='utf-8', errors='replace'):
        line = raw.rstrip('\n')
        m = OPEN.match(line)
        if m:
            ind = len(m.group(1))
            while len(stack) > 1 and stack[-1][0] >= ind:
                stack.pop()
            fld = pending.get(ind, '')
            n = Node(m.group(2), m.group(3), fld, stack[-1][1])
            stack[-1][1].kids.append(n)
            stack.append((ind, n))
            continue
        m = FIELD.match(line)
        if m:
            ind = len(m.group(1))
            name, val = m.group(2), m.group(3)
            while len(stack) > 1 and stack[-1][0] >= ind:
                stack.pop()
            owner = stack[-1][1]
            # `|vpiParent:` and the other back-edges open a child object we do
            # NOT want in the tree; mark the field so the opener can skip it.
            pending[ind] = name
            if val != '':
                owner.attrs.setdefault(name, []).append(val)
            continue
    return root


BACK = {'vpiParent', 'vpiActual', 'vpiInstance', 'vpiClassDefn', 'vpiTypedef',
        'vpiLowConn', 'vpiHighConn', 'vpiExpr'}


def enc(n):
    if n.kind == 'constant':
        a = n.attrs
        tag = '?'
        for k in ('UINT', 'INT', 'BIN', 'HEX', 'OCT', 'DEC', 'REAL', 'STRING',
                  'SCAL'):
            if k in a:
                tag = '%s:%s' % (k, a[k][0])
                break
        sz = a.get('vpiSize', ['-'])[0]
        ct = a.get('vpiConstType', ['-'])[0]
        return 'const %s@%s ct%s' % (tag, sz, ct)
    if n.kind == 'operation':
        ops = [k.kind for k in n.kids if k.field == 'vpiOperand']
        return 'op%s(%s)' % (n.attrs.get('vpiOpType', ['?'])[0], ','.join(ops))
    if n.kind in ('ref_obj', 'hier_path'):
        nm = n.head.split(',')[0].strip()
        return '%s %s' % (n.kind, nm)
    return n.kind


def chain(n, sect):
    out = []
    p = n.parent
    while p is not None and p is not sect.parent:
        nm = ''
        h = p.head.split(',')[0].strip()
        if h.startswith('(') or h:
            nm = h
        out.append('%s%s' % (p.kind, ('%s' % nm) if nm else ''))
        p = p.parent
    return '/'.join(out[:4]) if out else '-'


def walk(n, sect, rows, seen):
    if n.kind == 'range' and id(n) not in seen:
        seen.add(id(n))
        for side, fld in (('L', 'vpiLeftRange'), ('R', 'vpiRightRange')):
            k = [c for c in n.kids if c.field == fld]
            rows.append((sect.field or 'pool', chain(n, sect), n.loc,
                         side, enc(k[0]) if k else '<none>',
                         k[0].loc if k else '-'))
    for c in n.kids:
        if c.field in BACK:
            continue
        walk(c, sect, rows, seen)


def main():
    root = parse(sys.argv[1])
    rows = []
    seen = set()
    # Top-level sections: the design's own fields each open a list.
    for c in root.kids:
        sect = Node(c.field or 'pool', '', '', None)
        walk(c, c, rows, seen)
        _ = sect
    # de-dup identical rows but KEEP the count — a shared object appears once
    # per reachable path and the multiplicity is itself a measurement.
    from collections import Counter
    cnt = Counter(rows)
    for r, c in sorted(cnt.items()):
        print('%-14s %-52s %-10s %s %-34s %-10s x%d' % (r[0], r[1], r[2], r[3],
                                                        r[4], r[5], c))
    print('-- ranges=%d rows=%d' % (len(seen), sum(cnt.values())))


if __name__ == '__main__':
    main()
