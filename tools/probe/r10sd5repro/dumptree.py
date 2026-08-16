#!/usr/bin/env python3
"""r10uvm67 — a uhdm-dump PARSER, shared by every instrument in this pass.

The dump is an indented tree:

      \\_<kind>: (<name>), file:<f>, line:L:C, endln:L:C      <- an OBJECT
        |<field>:                                            <- a FIELD label
        \\_<kind>: ...                                        <- the field's value

Traps encoded here, each one paid for by an earlier pass in this campaign:

  * THE FIRST LINE IS THE DATABASE PATH and always differs between two
    workdirs -> callers pass `sed 1d` dumps, and this parser also drops a
    leading line that has no `\\_`.
  * `file:<path>` EMBEDS THE WORKDIR, so cross-workdir comparisons must
    normalise it away: `norm_obj()` strips the file: field entirely.
  * AN OBJECT IS NOT A DUMP OCCURRENCE.  The same object is printed once with
    its children and again, childlessly, wherever it is referenced
    (vpiParent back-references, vpiActual, ...).  `is_backref()` marks the
    childless prints so a census can count OBJECTS, not TEXT.
  * indentation is 2 spaces per level for fields, and an object's own children
    are indented relative to it — the parser keys on the column of the `\\_`.
"""
import re
import sys

OBJ = re.compile(r'^(?P<ind>\s*)\\_(?P<kind>[A-Za-z_0-9]+): ?(?P<rest>.*)$')
FLD = re.compile(r'^(?P<ind>\s*)\|(?P<name>[A-Za-z_0-9]+):(?P<val>.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
# Two spellings, and MISSING THE SECOND ONE COST THIS PASS A FALSE "0 full
# prints of module_inst(work@top)":
#   \_class_defn: (work@env), ...            -> name in parentheses
#   \_module_inst: work@top (work@top), ...  -> vpiName THEN (vpiFullName)
# The parenthesised form is the FULLNAME in both cases, so key on it.
NAM = re.compile(r'^(?:\S+ )?\((?P<n>[^)]*)\)')


class Node:
    __slots__ = ('kind', 'name', 'span', 'fields', 'children', 'parent',
                 'line', 'raw')

    def __init__(self, kind, name, span, line, raw):
        self.kind = kind
        self.name = name
        self.span = span
        self.line = line          # 1-based line number in the dump
        self.raw = raw
        self.fields = {}          # scalar fields: name -> value
        self.children = []        # (field_name, Node)
        self.parent = None

    def field_kids(self, fname):
        return [n for f, n in self.children if f == fname]

    def key(self):
        return (self.kind, self.name, self.span)

    def __repr__(self):
        return '%s(%s)@%s' % (self.kind, self.name, self.span)


def parse(path):
    """Returns (roots, all_nodes).  all_nodes is every OBJECT PRINT."""
    roots = []
    nodes = []
    stack = []            # (column, Node)
    field_stack = []      # (column, field name) — the label an object hangs on
    with open(path, 'rt', errors='replace') as fh:
        for ln, raw in enumerate(fh, 1):
            raw = raw.rstrip('\n')
            m = OBJ.match(raw)
            if m:
                col = len(m.group('ind'))
                rest = m.group('rest')
                nm = ''
                mn = NAM.match(rest)
                if mn:
                    nm = mn.group('n')
                ml = LOC.search(rest)
                span = ('%s:%s-%s:%s' % ml.groups()) if ml else ''
                node = Node(m.group('kind'), nm, span, ln, raw)
                while stack and stack[-1][0] >= col:
                    stack.pop()
                while field_stack and field_stack[-1][0] > col:
                    field_stack.pop()
                fname = ''
                if field_stack and field_stack[-1][0] <= col:
                    fname = field_stack[-1][1]
                if stack:
                    par = stack[-1][1]
                    node.parent = par
                    par.children.append((fname, node))
                else:
                    roots.append(node)
                stack.append((col, node))
                nodes.append(node)
                continue
            m = FLD.match(raw)
            if m:
                col = len(m.group('ind'))
                while field_stack and field_stack[-1][0] >= col:
                    field_stack.pop()
                field_stack.append((col, m.group('name')))
                while stack and stack[-1][0] >= col:
                    stack.pop()
                if stack:
                    v = m.group('val')
                    if v != '':
                        stack[-1][1].fields.setdefault(m.group('name'), v)
    return roots, nodes


def is_backref(n):
    """A childless print of an object that is defined elsewhere."""
    return not n.children


def norm(s):
    return re.sub(r'file:[^,]*,\s*', '', s).strip()


if __name__ == '__main__':
    roots, nodes = parse(sys.argv[1])
    print('roots=%d nodes=%d' % (len(roots), len(nodes)))
    for r in roots[:5]:
        print(' ', r, 'kids=%d' % len(r.children))
