#!/usr/bin/env python3
"""r11u7 — read, per interface_inst VIEW, the COMPARE-VISIBLE shape of every
param_assign Rhs from a uhdm-dump.

Prints one line per param_assign:  <view> | <param> | ovr=<0/1> | <shape>

<shape> is the Rhs tree in prefix form, carrying only fields a generated
`Compare` reads: the object kind, `vpiOpType`, `vpiSize`, the value line, and
the NAME of the typespec a `vpiTypespec` ref resolves to (`ts=<name>` /
`ts=-` when absent).  Spans, ids, fullnames and parents are deliberately
dropped -- no generated Compare reads one.

uhdm-dump prints a repeated OBJECT as a bare header with no children; such a
node is rendered `<elided:kind>` so a reader never mistakes an elision for an
empty cell (the r11u4 sharing trap).
"""
import re, sys

def parse(path):
    rows = []
    for raw in open(path, 'rt', errors='replace'):
        line = raw.rstrip('\n')
        if not line.strip():
            continue
        m = re.match(r'^(\s*)(\\_|\|)(.*)$', line)
        if not m:
            continue
        indent, mark, rest = len(m.group(1)), m.group(2), m.group(3)
        rows.append((indent, mark, rest))
    return rows

class Node:
    __slots__ = ('kind', 'head', 'fields', 'kids')
    def __init__(self, kind, head):
        self.kind, self.head, self.fields, self.kids = kind, head, {}, []

def build(rows):
    root = Node('ROOT', '')
    stack = [(-1, root, None)]      # indent, node, pending-label
    for indent, mark, rest in rows:
        while len(stack) > 1 and stack[-1][0] >= indent:
            stack.pop()
        parent = stack[-1][1]
        if mark == '|':
            if ':' in rest:
                lab, _, val = rest.partition(':')
                if val != '' or not lab.startswith('vpi'):
                    parent.fields[lab] = val
                stack[-1] = (stack[-1][0], parent, lab)
            continue
        kind = rest.split(':', 1)[0].strip()
        n = Node(kind, rest)
        lab = stack[-1][2] or 'child'
        parent.kids.append((lab, n))
        stack.append((indent, n, None))
    return root

def walk(node, fn):
    fn(node)
    for _, k in node.kids:
        walk(k, fn)

def tsname(node):
    for lab, k in node.kids:
        if lab == 'vpiTypespec' and k.kind == 'ref_typespec':
            for lab2, k2 in k.kids:
                if lab2 == 'vpiActual':
                    nm = re.search(r'\((.*?)\)', k2.head)
                    return k2.kind + '(' + (nm.group(1) if nm else '') + ')'
            return 'ref?'
    return '-'

VALUE_LABELS = ('UINT', 'INT', 'STRING', 'REAL', 'LOGIC', 'BIN', 'HEX', 'SCALAR')

def shape(node, depth=0):
    if node is None:
        return '<null>'
    if node.kind in ('operation',):
        ops = [k for lab, k in node.kids if lab == 'vpiOperand']
        if not ops and not node.fields:
            return '<elided:operation>'
        inner = ','.join(shape(o, depth + 1) for o in ops)
        sz = node.fields.get('vpiSize', '')
        return 'op%s%s[ts=%s](%s)' % (node.fields.get('vpiOpType', '?'),
                                      ('/sz' + sz) if sz else '',
                                      tsname(node), inner)
    if node.kind == 'tagged_pattern':
        pat = [k for lab, k in node.kids if lab == 'vpiPattern']
        return 'tagged[key=%s](%s)' % (tsname(node),
                                       shape(pat[0], depth + 1) if pat else '?')
    if node.kind == 'constant':
        v = ''
        for f, val in node.fields.items():
            if f in VALUE_LABELS:
                v = f + ':' + val
        if not v and not node.fields:
            return '<elided:constant>'
        return 'const(%s,sz=%s,ct=%s,ts=%s)' % (
            v, node.fields.get('vpiSize', '-'),
            node.fields.get('vpiConstType', '-'), tsname(node))
    if not node.kids and not node.fields:
        return '<elided:%s>' % node.kind
    nm = re.search(r'\((.*?)\)', node.head)
    return '%s(%s)' % (node.kind, nm.group(1) if nm else '')

def main(path):
    root = build(parse(path))
    seen = set()
    out = []
    def visit(n):
        if n.kind != 'interface_inst':
            return
        m = re.match(r'interface_inst:\s*(\S+)\s*\((.*?)\)', n.head)
        if not m:
            return
        view = m.group(2)
        pas = [k for lab, k in n.kids if lab == 'vpiParamAssign']
        if not pas:
            return
        key = view
        if key in seen:
            return
        seen.add(key)
        for pa in pas:
            lhs = [k for lab, k in pa.kids if lab == 'vpiLhs']
            rhs = [k for lab, k in pa.kids if lab == 'vpiRhs']
            pname = ''
            if lhs:
                pname = lhs[0].fields.get('vpiName', '')
                if not pname:
                    mm = re.search(r'\((.*?)\)', lhs[0].head)
                    pname = (mm.group(1).rsplit('.', 1)[-1] if mm else '?')
            out.append('%-28s %-8s ovr=%s  %s' % (
                view, pname, pa.fields.get('vpiOverriden', '0'),
                shape(rhs[0]) if rhs else '<null>'))
    walk(root, visit)
    for l in out:
        print(l)

if __name__ == '__main__':
    main(sys.argv[1])
