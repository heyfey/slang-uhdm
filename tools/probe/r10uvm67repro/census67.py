#!/usr/bin/env python3
"""r10uvm67 — SPAN-KEYED CENSUS OF BOTH SIDES, the brief's first instruction.

  usage: census67.py <g.dump> <o.dump> <span-or-name> [<span-or-name> ...]

For every OBJECT PRINT whose `kind@span` or whose name matches one of the keys,
print the CONTAINER PATH (the chain of package / module_inst / class_defn /
design ancestors, which is the only part of the path that identifies a VIEW),
the field it hangs on, and its scalar fields.  Golden LHS first, ours RHS
second, then the multiset difference of the (container-path, field, kind, span)
keys — so a missing COPY and a wrong FIELD look different in the output.

An object printed childlessly is a BACK-REFERENCE, not an object; it is counted
in its own column and never mixed with definitions.
"""
import collections
import sys

from dumptree import parse, is_backref

VIEWKINDS = ('package', 'module_inst', 'class_defn', 'design', 'interface_inst',
             'program', 'udp_defn', 'gen_scope')


def viewpath(n):
    out = []
    p = n.parent
    while p is not None:
        if p.kind in VIEWKINDS:
            out.append('%s(%s)' % (p.kind, p.name or ''))
        p = p.parent
    return '/'.join(reversed(out)) or '-TOP-'


def fieldof(n):
    if n.parent is None:
        return '-ROOT-'
    for f, k in n.parent.children:
        if k is n:
            return f or '-'
    return '?'


def matches(n, keys):
    tag = '%s@%s' % (n.kind, n.span)
    for k in keys:
        if k == tag or k == n.span or (n.name and k in n.name):
            return True
    return False


def census(path, keys):
    _roots, nodes = parse(path)
    rows = []
    for n in nodes:
        if matches(n, keys):
            rows.append((viewpath(n), fieldof(n), n.kind, n.span, n.name,
                         is_backref(n),
                         ';'.join('%s=%s' % kv for kv in sorted(n.fields.items())
                                  if kv[0] not in ('vpiFile',)),
                         n.line))
    return rows


def main():
    g, o = sys.argv[1], sys.argv[2]
    keys = sys.argv[3:]
    gr = census(g, keys)
    orr = census(o, keys)
    for tag, rows in (('GOLDEN(LHS)', gr), ('OURS(RHS)', orr)):
        print('== %s: %d prints ==' % (tag, len(rows)))
        for r in rows:
            print('  %-58s %-16s %-14s %-22s %s%s  [dumpline %d]'
                  % (r[0][:58], r[1], r[2], r[3], 'BACKREF ' if r[5] else '',
                     r[6][:110], r[7]))

    def keyms(rows):
        return collections.Counter(
            (r[0], r[1], r[2], r[3], r[5]) for r in rows)
    gk, ok = keyms(gr), keyms(orr)
    print('== MULTISET DIFF (golden - ours) ==')
    for k in sorted(set(gk) | set(ok)):
        if gk[k] != ok[k]:
            print('  g=%-3d o=%-3d %s' % (gk[k], ok[k], k))


if __name__ == '__main__':
    main()
