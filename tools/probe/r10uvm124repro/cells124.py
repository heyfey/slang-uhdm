#!/usr/bin/env python3
"""r10uvm124 — census of every `method_func_call` in a uhdm-dump together with
its `vpiPrefix` receiver object and its argument count.  MEASUREMENT ONLY; the
official `uhdm-cmp` is the judge.  LHS is ALWAYS golden.

THE KEY is

    <call start>|<call name BASE>|<prefix start>|<prefix name BASE>

where a NAME BASE is the VpiName truncated at its first `[`.  Both halves this
pass touches — the call's own VpiName/span and the prefix's VpiName/span — are
on the VALUE side, so a key that carried them could not see a cell move; the
NAME BASE is invariant under the law BY CONSTRUCTION (the law only strips a
`[...]` suffix off a name and shortens the span that follows it), and carrying
it keeps two unrelated call sites that share a `line:col` in two different
source files (UVM is a hundred `.svh` files under one `uvm_pkg.sv`) out of one
another's cells.  The VALUE is the whole shape:

    mfc=<VpiName>@<endline:endcol> args=<n> pfx=<kind>|<VpiName>|<span>

`VpiName` is read off the object's own `|vpiName:` line, never off the
parenthesised header — the dump SYNTHESIZES that header's fullname from the
parent chain (RESUME §9), and no generated `Compare` reads `VpiFullName`.

Rows are a MULTISET: one line per distinct (key, value) with its multiplicity,
so a colliding key can never drop a row in the join.

  usage: cells124.py <dump> [name-substring-of-the-call]
"""
import sys, re
from collections import Counter

MFC = re.compile(r'\\_method_func_call: \([^)]*\), line:(\d+):(\d+), endln:(\d+):(\d+)')
HDR = re.compile(r'\\_([a-z_]+): .*?line:(\d+):(\d+), endln:(\d+):(\d+)')
HDR_NOLOC = re.compile(r'\\_([a-z_]+): ')


def indent(l):
    return len(l) - len(l.lstrip())


def own_name(lines, i):
    """The `|vpiName:` written at object `i`'s OWN indent, or ''."""
    base = indent(lines[i])
    for j in range(i + 1, len(lines)):
        l = lines[j]
        if not l.strip():
            continue
        ind = indent(l)
        if l.lstrip().startswith('\\_') and ind <= base:
            break
        if ind <= base and not l.lstrip().startswith('|') and \
           not l.lstrip().startswith('\\_'):
            break
        if ind == base + 2 and l.lstrip().startswith('|vpiName:'):
            return l.split('|vpiName:', 1)[1].strip()
    return ''


def describe(lines, j):
    """kind|VpiName|span of the object whose header line is `j`."""
    m = HDR.search(lines[j])
    if m:
        return '%s|%s|%s:%s-%s:%s' % (m.group(1), own_name(lines, j),
                                      m.group(2), m.group(3),
                                      m.group(4), m.group(5))
    m = HDR_NOLOC.search(lines[j])
    if m:
        return '%s|%s|<noloc>' % (m.group(1), own_name(lines, j))
    return '<unparsed>'


def main():
    lines = open(sys.argv[1], errors='replace').read().split('\n')
    want = sys.argv[2] if len(sys.argv) > 2 else ''
    rows = Counter()
    for i, l in enumerate(lines):
        m = MFC.search(l)
        if not m:
            continue
        # A `|vpiParent:` back-reference re-prints the owner's HEADER with no
        # body; counting it would manufacture a phantom cell (and one whose
        # name reads empty).  The census counts DECLARATION sites only.
        k = i - 1
        while k >= 0 and not lines[k].strip():
            k -= 1
        if k >= 0 and lines[k].lstrip() == '|vpiParent:':
            continue
        base = indent(l)
        pfx = '<none>'
        nargs = 0
        for j in range(i + 1, len(lines)):
            s = lines[j]
            if not s.strip():
                continue
            ind = indent(s)
            if s.lstrip().startswith('\\_') and ind <= base:
                break
            if ind <= base and not s.lstrip().startswith('|') and \
               not s.lstrip().startswith('\\_'):
                break
            if ind != base + 2:
                continue
            if s.lstrip() == '|vpiPrefix:':
                pfx = describe(lines, j + 1)
            elif s.lstrip() == '|vpiArgument:':
                nargs += 1
        nm = own_name(lines, i)
        if want and want not in nm:
            continue
        pstart = pfx.split('|')[-1].split('-')[0] if pfx != '<none>' else '-'
        pname = pfx.split('|')[1] if pfx != '<none>' else '-'
        key = '%s:%s|%s|%s|%s' % (m.group(1), m.group(2), nm.split('[')[0],
                                  pstart, pname.split('[')[0])
        val = 'mfc=%s@%s:%s args=%d pfx=%s' % (nm, m.group(3), m.group(4),
                                               nargs, pfx)
        rows[(key, val)] += 1
    for k in sorted(rows):
        print('%d\t%s\t%s' % (rows[k], k[0], k[1]))


main()
