#!/usr/bin/env python3
"""r10rgg7/dumptree.py -- an INDENT tree parser for uhdm-dump output.

GUARDS (each an ops trap this campaign has paid for):
  * uhdm-dump prints BACK-REFERENCES (vpiParent, and any singular field whose
    target was already printed) as one-level-deep children.  Every walker here
    takes an explicit SKIP set of field labels so a parent reference is never
    counted as containment.
  * a node is identified by (kind, name, loc) -- NEVER by id, which is
    address/serialisation order, and never by fullname alone.
  * find_* helpers return a LIST and the callers COUNT it, so "no match" is a
    printed 0 and never silent agreement.
"""
import re, sys

LINE = re.compile(r'^(?P<ind>\s*)(?:(?P<label>\|[A-Za-z_0-9]+:)(?P<lval>.*)|'
                  r'\\_(?P<kind>[a-zA-Z_0-9]+): ?(?P<rest>.*))$')
# The dump's very first object line (`design: (work@rggen)`) carries NO `\_`
# and sits at indent 0, the same indent as the `|uhdmallModules:` labels that
# follow it -- parsed naively it is dropped and every view looks EMPTY.
ROOTLINE = re.compile(r'^(?P<kind>[a-zA-Z_0-9]+): ?(?P<rest>.*)$')

SKIP_DEFAULT = {'|vpiParent:'}


class Node:
    __slots__ = ('kind', 'rest', 'name', 'loc', 'label', 'fields', 'kids', 'ind', 'lineno')

    def __init__(self, kind, rest, label, ind, lineno):
        self.kind = kind
        self.rest = rest
        self.label = label
        self.ind = ind
        self.lineno = lineno
        self.fields = {}      # '|vpiName:' -> value (last wins)
        self.kids = []        # (label, Node)
        m = re.match(r'^(?P<dn>\S+)? ?\((?P<nm>[^)]*)\)(?P<tail>.*)$', rest or '')
        self.name = m.group('nm') if m else ''
        lm = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', rest or '')
        self.loc = ':'.join(lm.groups()) if lm else ''

    def defname(self):
        m = re.match(r'^(\S+) \(', self.rest or '')
        return m.group(1) if m else ''

    def kids_of(self, label, skip=SKIP_DEFAULT):
        return [n for (l, n) in self.kids if l == label and l not in skip]

    def sig(self):
        return '%s|%s|%s' % (self.kind, self.name, self.loc)


def parse(path):
    root = Node('design', '', None, -1, 0)
    stack = [root]
    pending_label = None
    with open(path, 'rt', errors='replace') as f:
        for ln, raw in enumerate(f, 1):
            raw = raw.rstrip('\n')
            m = LINE.match(raw)
            if not m:
                rm = ROOTLINE.match(raw)
                if rm and len(stack) == 1:
                    nd = Node(rm.group('kind'), rm.group('rest'), None, -1, ln)
                    root.kids.append((None, nd))
                    stack.append(nd)
                continue
            ind = len(m.group('ind'))
            while len(stack) > 1 and ind <= stack[-1].ind:
                stack.pop()
            if m.group('label'):
                lab = m.group('label')
                val = m.group('lval')
                if val == '':
                    pending_label = (ind, lab)
                else:
                    stack[-1].fields[lab] = val
                    pending_label = None
                continue
            nd = Node(m.group('kind'), m.group('rest'), None, ind, ln)
            lab = None
            if pending_label and pending_label[0] == ind:
                lab = pending_label[1]
            nd.label = lab
            stack[-1].kids.append((lab, nd))
            stack.append(nd)
            pending_label = None
    return root


def walk(node, skip=SKIP_DEFAULT):
    """Pre-order over CONTAINMENT edges only."""
    yield node
    for (lab, k) in node.kids:
        if lab in skip:
            continue
        yield from walk(k, skip)
