#!/usr/bin/env python3
"""r10uvm175 — the ELEMENT-SHAPE VECTOR of every `hier_path` in a uhdm-dump.

MEASUREMENT ONLY.  The official `uhdm-cmp` is the judge; nothing here decides
acceptance.  **LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.**

ONE ROW PER `hier_path`:

    KEY   = <path start line:col>|<path VpiName>
    VALUE = <elem0 shape>;<elem1 shape>;...

    elem shape = <kind>|<VpiName>|<start:col-end:col>|idx=<index shape>
    index shape = <kind>@<span>^<parent kind>      (or `-` when absent)

WHY THIS KEY.  The law this pass measures changes ONLY the ELEMENTS of a path
(a text-subscripted `ref_obj` becomes a `bit_select` named for the base with a
`vpiIndex` child and a shorter span).  It never changes the path's own VpiName
(that name is composed from the written text on both sides) and never changes
where the path STARTS.  So the key is invariant under the law BY CONSTRUCTION
and the whole moving part is on the value side — a key carrying an element
shape could not see a cell move.  The path END column is deliberately NOT in
the key: the `with`-clause span is a live field of a neighbouring law.

`VpiName` is read off the object's OWN `|vpiName:` line, never off the
parenthesised dump header — the dump SYNTHESIZES that header from the parent
chain (RESUME.md §9), and no generated `Compare` reads `VpiFullName`.
`VpiFullName` is therefore reported separately (`--full`) and never scored.

Rows are a MULTISET: one line per distinct (key, value) with its multiplicity,
so a colliding key can never drop a row in a join (RESUME.md §9).

  usage: cells175.py <dump> [--full]
"""
import sys
import re
from collections import Counter

HDR = re.compile(r'\\_([a-z_]+): .*?line:(\d+):(\d+), endln:(\d+):(\d+)')
HDR_NOLOC = re.compile(r'\\_([a-z_]+): ')


def indent(line):
    return len(line) - len(line.lstrip())


def own_field(lines, i, field):
    """The `|<field>:` written at object `i`'s OWN indent, or ''."""
    base = indent(lines[i])
    for j in range(i + 1, len(lines)):
        l = lines[j]
        if not l.strip():
            continue
        ind = indent(l)
        if l.lstrip().startswith('\\_') and ind <= base:
            break
        if ind <= base and not l.lstrip().startswith('|'):
            break
        if ind == base + 2 and l.lstrip().startswith('|' + field + ':'):
            return l.split('|' + field + ':', 1)[1].strip()
    return ''


def own_rel(lines, i, rel):
    """Header line index of the child on relation `|<rel>:` of object `i`."""
    base = indent(lines[i])
    for j in range(i + 1, len(lines)):
        l = lines[j]
        if not l.strip():
            continue
        ind = indent(l)
        if l.lstrip().startswith('\\_') and ind <= base:
            break
        if ind <= base and not l.lstrip().startswith('|'):
            break
        if ind == base + 2 and l.lstrip() == '|' + rel + ':':
            k = j + 1
            while k < len(lines) and not lines[k].strip():
                k += 1
            if k < len(lines) and lines[k].lstrip().startswith('\\_'):
                return k
            return -1
    return -1


def kind_span(lines, j):
    m = HDR.search(lines[j])
    if m:
        return m.group(1), '%s:%s-%s:%s' % (m.group(2), m.group(3),
                                            m.group(4), m.group(5))
    m = HDR_NOLOC.search(lines[j])
    if m:
        return m.group(1), '<noloc>'
    return '<unparsed>', '<noloc>'


def parent_kind(lines, j):
    k = own_rel(lines, j, 'vpiParent')
    if k < 0:
        return '-'
    return kind_span(lines, k)[0]


def elem_shape(lines, j, want_full):
    kind, span = kind_span(lines, j)
    nm = own_field(lines, j, 'vpiName')
    idx = own_rel(lines, j, 'vpiIndex')
    if idx < 0:
        ish = '-'
    else:
        ik, isp = kind_span(lines, idx)
        ish = '%s@%s^%s' % (ik, isp, parent_kind(lines, idx))
    out = '%s|%s|%s|idx=%s' % (kind, nm, span, ish)
    if want_full:
        out += '|full=%s' % own_field(lines, j, 'vpiFullName')
    return out


def path_rows(lines, want_full):
    rows = Counter()
    for i, l in enumerate(lines):
        if '\\_hier_path: ' not in l:
            continue
        # only the OWNING appearance: a dump repeats a hier_path header under
        # every child's `|vpiParent:`.  The owning one is the one that carries
        # `|vpiActual:` children at its own indent+2.
        base = indent(l)
        elems = []
        j = i + 1
        saw_body = False
        while j < len(lines):
            ln = lines[j]
            if not ln.strip():
                j += 1
                continue
            ind = indent(ln)
            if ln.lstrip().startswith('\\_') and ind <= base:
                break
            if ind <= base and not ln.lstrip().startswith('|'):
                break
            if ind == base + 2 and ln.lstrip().startswith('|'):
                saw_body = True
                if ln.lstrip() == '|vpiActual:':
                    k = j + 1
                    while k < len(lines) and not lines[k].strip():
                        k += 1
                    if k < len(lines) and lines[k].lstrip().startswith('\\_'):
                        elems.append(elem_shape(lines, k, want_full))
            j += 1
        if not saw_body or not elems:
            continue
        m = HDR.search(l)
        if not m:
            continue
        key = '%s:%s|%s' % (m.group(2), m.group(3), own_field(lines, i,
                                                              'vpiName'))
        rows[(key, ';'.join(elems))] += 1
    return rows


def main():
    want_full = '--full' in sys.argv[2:]
    lines = open(sys.argv[1], errors='replace').read().split('\n')
    rows = path_rows(lines, want_full)
    for (k, v), n in sorted(rows.items()):
        print('%s\t%s\tx%d' % (k, v, n))


if __name__ == '__main__':
    main()
