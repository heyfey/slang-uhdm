#!/usr/bin/env python3
"""r10uvm220repro/cen220.py — THE SCORER.

Reads a `uhdm-dump` listing and reports, for every `foreach_stmt`, the
ITERATED-ARRAY reference (`vpiVariables`) and its typespec, plus the loop
variable (`vpiLoopVars`) and its typespec.

The census key is the CELL, not the object: (view, holder, iterated-name,
line:col of the reference).  The value is
    <ref kind>|<typespec kind>|<typespec name>|<typespec line:col>
so a resolved typespec and a placeholder are distinguishable, AND a placeholder
that moved to a different span is too.

`view` is the dump's top-level section (uhdmallModules / uhdmallInterfaces /
uhdmallPackages / uhdmallClasses / uhdmtopModules / uhdmtopPackages ...), read
off the section header line, so DEF and ELAB copies never collide in the
multiset.  Objects are keyed as a MULTISET; a last-writer dict would drop the
second of two foreach headers over the same formal (the sharing question).

usage:  cen220.py <dump> [<dump> ...]          -- print the census
        cen220.py --diff <dumpA> <dumpB>       -- A(golden) vs B(ours), MULTISET
"""
import re
import sys
from collections import Counter

SECT = re.compile(r'^(uhdm\w+):')
# An UNNAMED object dumps as `\_int_typespec: , line:...` with NO parenthesis —
# a regex that requires `(name)` silently drops every one of them and prints
# `<none>` for a typespec that is in fact RESOLVED.  The name group is optional.
NODE = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?(?:,? ?(?:file:\S+, )?line:(\d+):(\d+), endln:(\d+):(\d+))?')
FIELD = re.compile(r'^(\s*)\|(\w+):')


def parse(path):
    """Return a list of (view, kind, name, line, col, indent, fieldpath)."""
    rows = []
    view = '?'
    # stack of (indent, field-name) telling which member slot we are inside
    fstack = []
    with open(path, 'rt') as f:
        for ln in f:
            ln = ln.rstrip('\n')
            m = SECT.match(ln)
            if m:
                view = m.group(1)
                fstack = []
                continue
            m = FIELD.match(ln)
            if m:
                ind = len(m.group(1))
                if ind == 0:
                    # the dump's TOP-LEVEL member slots are the views
                    # (uhdmallInterfaces, uhdmtopModules, ...).
                    view = m.group(2)
                while fstack and fstack[-1][0] >= ind:
                    fstack.pop()
                fstack.append((ind, m.group(2)))
                continue
            m = NODE.match(ln)
            if m:
                ind = len(m.group(1))
                while fstack and fstack[-1][0] > ind:
                    fstack.pop()
                slot = fstack[-1][1] if fstack else '?'
                rows.append((view, m.group(2), m.group(3) or '', m.group(4),
                             m.group(5), ind, slot))
    return rows


def census(path):
    """Multiset of foreach cells."""
    rows = parse(path)
    out = Counter()
    n = len(rows)
    for i, (view, kind, name, line, col, ind, slot) in enumerate(rows):
        if kind != 'foreach_stmt' or slot == 'vpiParent':
            continue
        # walk forward while strictly deeper than the foreach node
        j = i + 1
        cur_role = None
        cur_ref = None
        while j < n and rows[j][5] > ind:
            v2, k2, n2, l2, c2, i2, s2 = rows[j]
            if s2 == 'vpiParent':
                j += 1
                continue
            if i2 == ind + 2 and s2 in ('vpiVariables', 'vpiLoopVars'):
                cur_role = s2
                cur_ref = (k2, n2, l2, c2)
                # look ahead for this ref's vpiTypespec -> vpiActual
                ts = ('<none>', '', '', '')
                k = j + 1
                while k < n and rows[k][5] > i2:
                    v3, k3, n3, l3, c3, i3, s3 = rows[k]
                    if s3 == 'vpiActual' and i3 == i2 + 4:
                        ts = (k3, n3, l3, c3)
                        break
                    if i3 == i2 + 2 and s3 not in ('vpiTypespec', 'vpiParent'):
                        break
                    k += 1
                key = (view, cur_role, cur_ref[1], '%s:%s' % (cur_ref[2], cur_ref[3]))
                val = '%s|%s|%s|%s:%s' % (cur_ref[0], ts[0], ts[1], ts[2], ts[3])
                out[(key, val)] += 1
            j += 1
    return out


def fmt(k, v):
    (view, role, name, span) = k
    return '%-22s %-14s %-22s %-10s %s' % (view, role, name, span, v)


def main():
    if sys.argv[1:2] == ['--diff']:
        a = census(sys.argv[2])
        b = census(sys.argv[3])
        keys = sorted(set(a) | set(b), key=lambda t: (t[0][0], t[0][3], t[0][2]))
        same = miss = extra = 0
        for k in keys:
            ca, cb = a[k], b[k]
            if ca == cb:
                same += ca
                continue
            if ca > cb:
                miss += ca - cb
                print('MISSING-OURS x%d  %s' % (ca - cb, fmt(k[0], k[1])))
            else:
                extra += cb - ca
                print('EXTRA-OURS   x%d  %s' % (cb - ca, fmt(k[0], k[1])))
        print('SAME=%d MISSING-OURS=%d EXTRA-OURS=%d' % (same, miss, extra))
        return
    for p in sys.argv[1:]:
        print('== %s' % p)
        c = census(p)
        for k in sorted(c, key=lambda t: (t[0][0], t[0][3], t[0][2])):
            print('  x%d %s' % (c[k], fmt(k[0], k[1])))


if __name__ == '__main__':
    main()
