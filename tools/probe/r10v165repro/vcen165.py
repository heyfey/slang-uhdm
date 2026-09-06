#!/usr/bin/env python3
"""r10v165repro/vcen165.py — the VERIFIER's OWN, independent argument census.

MEASUREMENT ONLY.  Reads a `uhdm-dump` text (never the emitter, never the
implementer's ct165cen) and reports, for every ARGUMENT of every call, whether
that argument carries a `vpiActual` (BOUND) or not (BARE).

It parses the dump as an indentation tree.  A `\\_...` object printed under a
`|vpiParent:` (or `|vpiTypespec:` / `|vpiInstance:` / `|vpiTaskFunc:`) field is
a BACK-REFERENCE and is not descended into, so nothing is counted twice from a
parent print-back.

Keys are MULTISETS (an elaborated package can hold a generic class body twice
at one span), and the key is the argument's own NAME and SPAN plus the call it
belongs to — never a fullname, never a file path.

usage: vcen165.py <dump> [--all]
"""
import re
import sys
from collections import Counter

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): (.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)')
NAM = re.compile(r'^\(([^)]*)\)')

BACKREF_FIELDS = {'vpiParent'}
ARG_FIELDS = {'vpiArgument', 'vpiTfCallArgs', 'vpiArguments'}
CALL_KINDS = {'method_func_call', 'func_call', 'tf_call', 'method_task_call',
              'task_call', 'sys_func_call', 'sys_task_call'}


def parse(path):
    """Yield (indent, kind, rest, field, stack) for every object line."""
    lines = open(path, errors='replace').read().split('\n')
    # stack of (indent, kind, name, loc, field_that_held_it)
    stack = []
    fld_at = {}          # indent -> field name most recently opened there
    out = []
    for ln in lines:
        m = FLD.match(ln)
        if m:
            fld_at[len(m.group(1))] = m.group(2)
            continue
        m = OBJ.match(ln)
        if not m:
            continue
        ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        field = fld_at.get(ind, '')
        nm = NAM.match(rest)
        name = nm.group(1) if nm else ''
        lm = LOC.search(rest)
        loc = '%s:%s' % (lm.group(1), lm.group(2)) if lm else '?'
        out.append((ind, kind, name, loc, field, list(stack)))
        stack.append((ind, kind, name, loc, field))
    return out, lines


def has_actual(lines, idx_line, indent):
    """The TARGET of the `|vpiActual:` of the object printed at dump line
    `idx_line` — `kind(name)@line:col` — or 'BARE' when it has none.  The
    TARGET, not merely its presence, is what `ref_obj::Compare` reads, so a
    reference bound to the WRONG object must not score as agreement."""
    i = idx_line + 1
    n = len(lines)
    want = False
    while i < n:
        ln = lines[i]
        if not ln.strip():
            i += 1
            continue
        m = FLD.match(ln)
        if m:
            if len(m.group(1)) <= indent:
                return 'BARE'
            want = (len(m.group(1)) == indent + 2 and m.group(2) == 'vpiActual')
            i += 1
            continue
        m = OBJ.match(ln)
        if m:
            if len(m.group(1)) <= indent:
                return 'BARE'
            if want and len(m.group(1)) == indent + 2:
                kind, rest = m.group(2), m.group(3)
                nm = NAM.match(rest)
                name = nm.group(1) if nm else ''
                if '::' in name:
                    name = name.rsplit('::', 1)[1]
                lm = LOC.search(rest)
                loc = '%s:%s' % (lm.group(1), lm.group(2)) if lm else '?'
                return 'BOUND->%s(%s)@%s' % (kind, name, loc)
            i += 1
            continue
        i += 1
    return 'BARE'


def main():
    path = sys.argv[1]
    show_all = '--all' in sys.argv
    nodes, lines = parse(path)
    # re-walk with line indices
    stack = []
    fld_at = {}
    cells = Counter()
    for i, ln in enumerate(lines):
        m = FLD.match(ln)
        if m:
            fld_at[len(m.group(1))] = m.group(2)
            continue
        m = OBJ.match(ln)
        if not m:
            continue
        ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        field = fld_at.get(ind, '')
        nm = NAM.match(rest)
        name = nm.group(1) if nm else ''
        if '::' in name:
            name = name.rsplit('::', 1)[1]
        lm = LOC.search(rest)
        loc = '%s:%s' % (lm.group(1), lm.group(2)) if lm else '?'
        under_backref = any(fr in BACKREF_FIELDS for (_, _, _, _, fr) in stack) \
            or field in BACKREF_FIELDS
        if not under_backref and field in ARG_FIELDS and stack and \
                stack[-1][1] in CALL_KINDS:
            call = stack[-1]
            b = has_actual(lines, i, ind)
            cells[('ARG', kind, name, loc, call[1], call[2], call[3], b)] += 1
        stack.append((ind, kind, name, loc, field))
    for k, c in sorted(cells.items()):
        print('%s|%s|%s|%s|call=%s(%s)@%s|%s|x%d' % (k + (c,)))


if __name__ == '__main__':
    main()
