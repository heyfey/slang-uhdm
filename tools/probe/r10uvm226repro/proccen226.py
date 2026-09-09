#!/usr/bin/env python3
"""r10uvm226 — the PROCESS census.

Reads a `uhdm-dump` text dump and emits ONE line per `vpiProcess` element of
every process HOLDER (interface_inst / module_inst / program / gen_scope), keyed
POSITIONALLY — `interface_inst::Compare` compares `Process()` as a VECTOR
(UHDM/build/generated/src/interface_inst.cpp:299), so multiplicity and order are
part of the judged value.

The payload is the WHOLE process subtree, flattened depth-first with the field
names kept, `vpiParent` never descended (it is the one field the dump prints as
a full re-expansion of an ancestor), and every dump `file:` path stripped to its
basename so two workdirs compare.  Recorded per node:

  the object KIND, and every scalar field the dump prints for it — which is a
  SUPERSET of what the judge reads, deliberately: `always::Compare` reads
  `VpiAlwaysType` (always.cpp:9), `process_stmt::Compare` reads `Stmt`,
  `Module_inst` and `Attributes` (process_stmt.cpp:8-10), `named_begin` reads
  `VpiEndLabel`, and `ref_obj` reads `Actual_group` — a census blind to any one
  of them reports AWAY 0 while a cell moves away on it (r10v224's R-C, r10v225's
  §2.1).  `vpiActual` IS descended one level and printed as `ACT=<kind>(<name>)`
  so a BINDING change is visible without re-expanding the whole referent.

SPAN=1 in the environment adds each node's `line:col..endln` to its payload;
the default leaves spans OUT, because no generated `Compare` reads
VpiFile/VpiLineNo/VpiColumnNo (RESUME §9).  Both readings are printed by the
scorer.

  usage: proccen226.py <dump> [<dump> ...]
  output: one sorted `CELL <holder>#<view>[<i>] | <payload>` line per process
"""
import os
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
SPAN = os.environ.get('SPAN', '0') == '1'
LOC = re.compile(r'line:\d+:\d+, endln:\d+:\d+')


def parse(path):
    roots = []
    stack = []
    pending_field = None
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
                if name.isupper():
                    if stack:
                        stack[-1][1].fields.append(
                            ('vpiValue', name + ':' + rest.strip()))
                    continue
                if rest.strip() == '':
                    pending_field = name
                elif stack:
                    stack[-1][1].fields.append((name, rest.strip()))
                continue
            m = VAL.match(line)
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


def kids(n, field):
    return [c for f, c in n.children if f == field]


HOLDERS = ('interface_inst', 'module_inst', 'program', 'gen_scope')


def brief(n):
    """One-token identity of an object reached through a back-reference."""
    nm = get(n, 'vpiName') or get(n, 'vpiFullName')
    if not nm:
        h = n.head.split(',')[0].strip()
        nm = h.strip('() ')
    return '%s(%s)' % (n.kind, nm)


def flatten(n, out, depth=0):
    """Depth-first, field-name-keyed flattening.  vpiParent is NEVER descended;
    vpiActual is descended ONE level only (the binding, not the referent)."""
    tok = [n.kind]
    if SPAN:
        m = LOC.search(n.head)
        tok.append('@' + (m.group(0) if m else '-'))
    for k, v in n.fields:
        if k in ('vpiFile',):
            continue
        tok.append('%s=%s' % (k, v))
    out.append('%d:%s' % (depth, ' '.join(tok)))
    for f, c in n.children:
        if f == 'vpiParent':
            continue
        if f == 'vpiActual':
            out.append('%d:ACT[%s]=%s' % (depth + 1, f, brief(c)))
            continue
        out.append('%d:<%s>' % (depth + 1, f))
        flatten(c, out, depth + 1)


def view_of(n):
    """DEF view or ELAB view.  Surelog labels the def copy `work@<name>` in its
    fullname and the elaborated one by its hierarchical path; the two producers
    label the view differently, so the census keys on the SHAPE of the fullname,
    not on any field either producer stamps (RESUME §8's census trap)."""
    full = get(n, 'vpiFullName') or get(n, 'vpiName')
    return 'DEF' if full.startswith('work@') and '.' not in full else 'ELAB'


def walk(n, out, skip=('vpiParent',)):
    if n.kind in HOLDERS:
        full = get(n, 'vpiFullName') or get(n, 'vpiName') or n.head
        key = '%s#%s' % (full, view_of(n))
        lst = kids(n, 'vpiProcess')
        # the richest listing per holder-view wins (the dump prints a holder
        # more than once through back-references)
        if lst and (key not in out or len(lst) > len(out[key])):
            out[key] = lst
        elif key not in out:
            out.setdefault(key, [])
    for f, c in n.children:
        if f in skip:
            continue
        walk(c, out, skip)


def main():
    for path in sys.argv[1:]:
        holders = {}
        for root in parse(path):
            walk(root, holders)
        rows = []
        for holder in sorted(holders):
            lst = holders[holder]
            if not lst:
                rows.append(('%s[-]' % holder, 'NO-PROCESS'))
                continue
            for i, p in enumerate(lst):
                acc = []
                flatten(p, acc)
                rows.append(('%s[%d]' % (holder, i), ' ; '.join(acc)))
        for k, d in rows:
            print('CELL %s | %s' % (k, d))


if __name__ == '__main__':
    main()
