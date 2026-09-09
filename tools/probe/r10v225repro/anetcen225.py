#!/usr/bin/env python3
"""r10uvm225 — the ARRAY_NET census.

Reads a `uhdm-dump` text dump and emits ONE line per `array_net` object with
every JUDGE-VISIBLE field the successor law has to get right:

  the array_net's own vpiSize / vpiName / vpiFullName / vpiNetType / typespec,
  ONE `R=` group per vpiRange (the left and right bound's decompile, value,
  vpiSize and vpiConstType, plus the right bound's index-typespec kind), and
  the INNER element net's kind, vpiNetType and typespec kind+name.

`netcen224.py` records the inner net's typespec and NOTHING else, and
`nets::Compare` reads `VpiNetType` (UHDM generated/src/nets.cpp:277) — a grid
blind to that field reports AWAY 0 while a cell moves away on it (r10v224's
R-C).  This scorer reads it, and `innernt224.py` is run beside it.

Subtrees under a back-reference field (`vpiParent`, `vpiActual` of a parent…)
are NOT descended: only `vpiParent` is skipped, since it is the one field the
dump prints as a full re-expansion of an ancestor.

  usage: anetcen225.py <dump> [<dump> ...]
  output: one sorted `CELL <key> | <fields>` line per array_net
"""
import re
import sys


class Node:
    __slots__ = ('kind', 'head', 'fields', 'children', 'indent')

    def __init__(self, kind, head, indent):
        self.kind = kind
        self.head = head
        self.indent = indent
        self.fields = []      # (name, value) scalar fields, in order
        self.children = []    # (fieldname, Node)


OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+):\s?(.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
VAL = re.compile(r'^(\s*)\|([A-Z]+:.*)$')


def parse(path):
    """Build the object forest.  Returns the list of ROOT nodes."""
    roots = []
    stack = []            # list of (indent, Node)
    pending_field = None  # the `|vpiX:` that the next `\_obj` belongs to
    with open(path, errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\n')
            m = OBJ.match(line)
            if m:
                ind, kind, head = len(m.group(1)), m.group(2), m.group(3)
                n = Node(kind, head, ind)
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                if stack:
                    stack[-1][1].children.append((pending_field or '?', n))
                else:
                    roots.append(n)
                stack.append((ind, n))
                pending_field = None
                continue
            m = FLD.match(line)
            if m:
                ind, name, rest = len(m.group(1)), m.group(2), m.group(3)
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                if name.isupper():          # a VALUE tag: `|UINT:1`, `|STRING:$`
                    if stack:
                        stack[-1][1].fields.append(
                            ('vpiValue', name + ':' + rest.strip()))
                    continue
                if rest.strip() == '':
                    pending_field = name
                elif stack:
                    stack[-1][1].fields.append((name, rest.strip()))
                continue
            m = VAL.match(line)          # `|UINT:0`, `|STRING:$`
            if m:
                ind, rest = len(m.group(1)), m.group(2)
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                if stack:
                    stack[-1][1].fields.append(('vpiValue', rest.strip()))
                continue
    return roots


def get(n, name, dflt=''):
    for k, v in n.fields:
        if k == name:
            return v
    return dflt


def kid(n, field):
    for f, c in n.children:
        if f == field:
            return c
    return None


def kids(n, field):
    return [c for f, c in n.children if f == field]


HOLDERS = ('interface_inst', 'module_inst', 'program', 'gen_scope')


def walk(n, out, skip=('vpiParent',)):
    """Collect (holder-fullname, [array_net...]) in DECLARATION ORDER.

    The judge compares `Array_nets()` as a VECTOR, so multiplicity and order
    matter: MiniAmiq's golden five include the SAME imported name twice.  Only
    array_nets that are a holder's own `vpiArrayNet` children are collected —
    a `vpiParent` back-reference is never descended, and the richest (longest)
    listing per holder wins when the dump prints a holder more than once.
    """
    if n.kind in HOLDERS:
        full = get(n, 'vpiFullName') or get(n, 'vpiName') or n.head
        lst = kids(n, 'vpiArrayNet')
        if lst and (full not in out or len(lst) > len(out[full])):
            out[full] = lst
    for f, c in n.children:
        if f in skip:
            continue
        walk(c, out, skip)


def ts_of(n):
    """typespec kind+name reached through a ref_typespec."""
    rt = kid(n, 'vpiTypespec')
    if rt is None:
        return 'none'
    act = kid(rt, 'vpiActual')
    if act is None:
        return 'ref(<null>)'
    nm = get(act, 'vpiName') or act.head.split(',')[0].strip()
    nm = nm.strip('() ')
    return '%s(%s)' % (act.kind, nm) if nm else act.kind


def const_desc(c):
    if c is None:
        return '<none>'
    return '%s d=%s v=%s sz=%s ct=%s ts=%s loc=%s' % (
        c.kind,
        get(c, 'vpiDecompile', '-'), get(c, 'vpiValue', '-'),
        get(c, 'vpiSize', '-'), get(c, 'vpiConstType', '-'),
        ts_of(c), 'y' if ',' in c.head or 'line:' in c.head else 'n')


def describe(an):
    full = get(an, 'vpiFullName')
    parts = ['size=%s' % get(an, 'vpiSize', '-'),
             'nt=%s' % get(an, 'vpiNetType', '-'),
             'ts=%s' % ts_of(an)]
    rngs = kids(an, 'vpiRange')
    parts.append('nranges=%d' % len(rngs))
    for i, r in enumerate(rngs):
        parts.append('R%d[L: %s | R: %s]' % (
            i, const_desc(kid(r, 'vpiLeftRange')),
            const_desc(kid(r, 'vpiRightRange'))))
    inner = kids(an, 'vpiNet')
    parts.append('ninner=%d' % len(inner))
    for i, e in enumerate(inner):
        parts.append('I%d[%s nt=%s ts=%s]' % (
            i, e.kind, get(e, 'vpiNetType', '-'), ts_of(e)))
    return full, ' '.join(parts)


def main():
    for path in sys.argv[1:]:
        holders = {}
        for root in parse(path):
            walk(root, holders)
        rows = []
        for holder in sorted(holders):
            for i, an in enumerate(holders[holder]):
                full, d = describe(an)
                rows.append(('%s[%d]=%s' % (holder, i, full), d))
        for k, d in rows:
            print('CELL %s | %s' % (k, d))


if __name__ == '__main__':
    main()
