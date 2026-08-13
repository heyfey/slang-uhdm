#!/usr/bin/env python3
"""r10earl40 — THE SELECT-SHAPE CENSUS, cell-keyed and VIEW-KEYED.

One row per assignment (`cont_assign` or procedural `assignment`) whose LHS
names a grid cell (`c_<cell>`), recording the SHAPE OF THE RHS as a compact
tree signature:

    <view> <cell> <rhskind> [<child summary> ...]

so a grid table can be printed cell for cell without a line table.

Why view-keyed: a def-view generate body is emitted TWICE — once into
`uhdmallModules` from SYNTAX and once into the elaborated `gen_scope` from the
bound AST — and r10earl32's cells32.py collapsed the two onto one row and
printed only the first (recorded as that pass's own instrument defect).  The
ELABORATED fullname carries `[i]` on every gen-for block, so the LHS fullname
separates the two views with no state machine.

Traps encoded (all inherited from argts39.py, which paid for them):
  * uhdm-dump prints an object's PARENT as a shallow back-reference stub under
    `|vpiParent:` AT THE SAME INDENT AS THE LABEL.  Those subtrees are DROPPED.
  * The dump is INDENTATION-structured: an object at indent I is introduced by
    a field label at indent I which belongs to the object at indent I-2.
  * A singular child object is printed AT ITS LABEL'S INDENT, not deeper.

usage: cells40.py <dump>            (dump must already be `sed 1d`-ed)
"""
import re
import sys

OBJ = re.compile(r'^( *)\\_([A-Za-z_0-9]+): *(\([^)]*\))?(.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

# Fields worth recording on a select-family object: these are exactly the
# fields the head's golden subtree carries and the ones a wrong emission would
# get wrong.
KEEP = ('vpiName', 'vpiFullName', 'vpiDefName', 'vpiConstantSelect',
        'vpiOpType', 'vpiDecompile', 'vpiSize', 'vpiConstType')


class Node:
    __slots__ = ('kind', 'paren', 'span', 'fields', 'kids', 'label')

    def __init__(self, kind, paren, span):
        self.kind = kind
        self.paren = paren
        self.span = span
        self.fields = {}
        self.kids = []          # (label, Node)
        self.label = None


def parse(path):
    """Return the list of ROOT nodes, with |vpiParent: stubs dropped."""
    roots = []
    stack = []               # (indent, Node)
    labels = {}              # indent -> last field label at that indent
    skip = None              # indent of a dropped |vpiParent: subtree
    for raw in open(path, errors='replace'):
        line = raw.rstrip('\n')
        m = FLD.match(line)
        if m:
            ind, name, val = len(m.group(1)), m.group(2), m.group(3)
            if skip is not None and ind > skip:
                continue
            skip = None
            labels[ind] = name
            if name == 'vpiParent':
                skip = ind
                continue
            # scalar field on the object at indent-2
            while stack and stack[-1][0] > ind - 2:
                stack.pop()
            if stack and stack[-1][0] == ind - 2:
                stack[-1][1].fields[name] = val
            continue
        m = OBJ.match(line)
        if not m:
            continue
        ind, kind, paren, rest = (len(m.group(1)), m.group(2),
                                  m.group(3) or '', m.group(4) or '')
        if skip is not None and ind >= skip:
            # the back-reference stub itself sits AT the label's indent
            continue
        skip = None
        sp = SPAN.search(rest)
        span = '%s:%s-%s:%s' % sp.groups() if sp else ''
        n = Node(kind, paren.strip('()'), span)
        n.label = labels.get(ind)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        if stack:
            stack[-1][1].kids.append((n.label, n))
        else:
            roots.append(n)
        stack.append((ind, n))
    return roots


def walk(nodes):
    for n in nodes:
        yield n
        for _, k in n.kids:
            yield from walk([k])


def sig(n, depth=0):
    """Compact recursive signature of a select-family subtree."""
    if n is None:
        return '<null>'
    out = n.kind
    bits = []
    for f in KEEP:
        if f in n.fields:
            v = n.fields[f].strip()
            bits.append('%s=%s' % (f, v))
    if 'UINT' in n.fields:
        bits.append('UINT=%s' % n.fields['UINT'].strip())
    if bits:
        out += '{' + ','.join(bits) + '}'
    out += '@' + n.span
    if depth < 4:
        kid = []
        for lbl, k in n.kids:
            if lbl in ('vpiIndex', 'vpiLeftRange', 'vpiRightRange',
                       'vpiOperand', 'vpiBaseExpr', 'vpiWidthExpr'):
                kid.append('%s=%s' % (lbl, sig(k, depth + 1)))
        if kid:
            out += '(' + ' '.join(kid) + ')'
    return out


def lhs_name(a):
    for lbl, k in a.kids:
        if lbl == 'vpiLhs':
            return k.fields.get('vpiName', '').strip(), \
                   k.fields.get('vpiFullName', '').strip()
    return '', ''


def rhs(a):
    for lbl, k in a.kids:
        if lbl == 'vpiRhs':
            return k
    return None


def main():
    roots = parse(sys.argv[1])
    rows = []
    for n in walk(roots):
        if n.kind not in ('cont_assign', 'assignment'):
            continue
        nm, full = lhs_name(n)
        if not nm.startswith('c_'):
            continue
        # ELAB view: the gen-for block carries [i] in the elaborated fullname.
        view = 'ELAB' if re.search(r'\[\d+\]', full) else 'DEF'
        r = rhs(n)
        rows.append((nm, view, sig(r)))
    for nm, view, s in sorted(set(rows)):
        print('%-24s %-4s %s' % (nm, view, s))


if __name__ == '__main__':
    main()
