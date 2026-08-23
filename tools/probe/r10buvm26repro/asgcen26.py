#!/usr/bin/env python3
"""r10buvm26 — census of ASSIGNMENT objects out of a `uhdm-dump` text.

MEASUREMENT ONLY.  The official `uhdm-cmp` is the acceptance judge.
LHS is ALWAYS golden, RHS is ALWAYS ours, everywhere this is used.

Emits one row per `assignment`, keyed by source location, carrying the
COMPARE-VISIBLE payload of the two slots the generated
`assignment::Compare` reads (`~/git-repos/UHDM/build/generated/src/
assignment.cpp:116-117`: Rhs FIRST, then Lhs):

    <tag>|<line:col-endline:endcol>|<opType>|<blocking>|RHS=<shape>|LHS=<shape>

`<shape>` is the object KIND, its `vpiName`, and — for a `hier_path` — the
kind/name of every `Path_elems` entry, recursively one level for a select's
index.  `vpiFullName`, `vpiFile` and `vpiParent` are NEVER part of the key:
no generated `Compare` reads them (RESUME.md §9).
"""
import re
import sys

HDR = re.compile(r'^(\s*)\\_([A-Za-z_]+): (\([^)]*\))?(.*)$')
LBL = re.compile(r'^(\s*)\|(vpi[A-Za-z_]+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


class Node:
    __slots__ = ('kind', 'loc', 'attrs', 'kids', 'indent')

    def __init__(self, kind, loc, indent):
        self.kind = kind
        self.loc = loc
        self.attrs = {}
        self.kids = {}          # label -> [Node]
        self.indent = indent


def parse(path, weak=False):
    """Build the object forest.  A `\\_kind:` line opens an object; the
    `|label:` line that precedes a deeper `\\_` line names the slot.

    Reading STOPS at the top-level `\\_weaklyReferenced:` marker unless
    `weak` is set: everything after it is the serializer's leftover listing,
    which no `Compare` walk reaches (RESUME.md §9, "the weaklyReferenced tail
    is unreachable to the judge").  Counting it makes a census report
    differences the official uhdm-cmp cannot see."""
    roots = []
    stack = []                  # (indent, node)
    pend = None                 # label awaiting its child
    with open(path, errors='replace') as fh:
        for raw in fh:
            line = raw.rstrip('\n')
            if not weak and line == '\\_weaklyReferenced:':
                break
            m = HDR.match(line)
            if m:
                ind = len(m.group(1))
                kind = m.group(2)
                lm = LOC.search(m.group(4) or '')
                loc = ('%s:%s-%s:%s' % lm.groups()) if lm else ''
                node = Node(kind, loc, ind)
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                if stack and pend is not None:
                    stack[-1][1].kids.setdefault(pend, []).append(node)
                else:
                    roots.append(node)
                pend = None
                stack.append((ind, node))
                continue
            m = LBL.match(line)
            if m:
                ind = len(m.group(1))
                lab, val = m.group(2), m.group(3)
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                if val.strip() == '':
                    pend = lab
                elif stack:
                    stack[-1][1].attrs[lab] = val
                continue
    return roots


def walk(n, out):
    # `vpiParent` back-references re-print an ancestor: following them would
    # count every object twice (and never terminate on a real cycle).
    out.append(n)
    for lab, lst in n.kids.items():
        if lab == 'vpiParent':
            continue
        for k in lst:
            walk(k, out)


def shape(n, depth=0):
    if n is None:
        return '<null>'
    nm = n.attrs.get('vpiName', '')
    s = '%s(%s)' % (n.kind, nm)
    if depth >= 2:
        return s
    parts = []
    for lab in ('vpiActual', 'vpiIndex', 'vpiPrefix', 'vpiExpr'):
        for k in n.kids.get(lab, []):
            parts.append(lab[3:].lower() + '=' + shape(k, depth + 1))
    if parts:
        s += '{' + ','.join(parts) + '}'
    return s


def one(n, kid):
    lst = n.kids.get(kid, [])
    return lst[0] if lst else None


def main():
    tag = sys.argv[2] if len(sys.argv) > 2 else '?'
    noloc = '--noloc' in sys.argv
    nodes = []
    for r in parse(sys.argv[1]):
        walk(r, nodes)
    rows = []
    for n in nodes:
        if n.kind not in ('assignment', 'assign_stmt', 'cont_assign'):
            continue
        loc = '' if noloc else n.loc
        rows.append('%s|%s|%s|%s|RHS=%s|LHS=%s' % (
            tag, loc, n.attrs.get('vpiOpType', ''),
            n.attrs.get('vpiBlocking', ''),
            shape(one(n, 'vpiRhs')), shape(one(n, 'vpiLhs'))))
    for r in sorted(rows):
        print(r)


if __name__ == '__main__':
    main()
