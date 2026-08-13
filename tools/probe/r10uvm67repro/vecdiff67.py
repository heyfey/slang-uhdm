#!/usr/bin/env python3
"""r10uvm67 — compare ONE named container's ONE vector, element by element.

  usage: vecdiff67.py <g.dump> <o.dump> <kind> <name> <field>

Prints both sides' vectors in ORDER with each element's identity (kind, span,
Lhs name for a param_assign) so a MISSING ELEMENT and a REORDER look different.
Back-reference prints (childless) are marked; a param_assign printed childlessly
is the SAME OBJECT as one printed in full elsewhere, which is itself the finding
when golden prints a fresh CLONE at the same slot.
"""
import sys

from dumptree import parse, is_backref


def ident(n):
    lhs = ''
    for f, k in n.children:
        if f == 'vpiLhs':
            lhs = k.name or k.kind
            break
    rhs = ''
    for f, k in n.children:
        if f == 'vpiRhs':
            rhs = '%s@%s' % (k.kind, k.span)
            break
    return '%s@%s lhs=%s rhs=%s%s' % (n.kind, n.span, lhs, rhs,
                                      ' BACKREF' if is_backref(n) else '')


def containers(path, kind, name):
    _r, nodes = parse(path)
    return [n for n in nodes
            if n.kind == kind and n.name == name and not is_backref(n)]


def main():
    g, o, kind, name, field = sys.argv[1:6]
    for tag, p in (('GOLDEN(LHS)', g), ('OURS(RHS)', o)):
        cs = containers(p, kind, name)
        print('== %s: %d full prints of %s(%s) ==' % (tag, len(cs), kind, name))
        for c in cs:
            kids = c.field_kids(field)
            print('  [dumpline %d] %s: %d elements' % (c.line, field, len(kids)))
            for i, k in enumerate(kids):
                print('    %3d  %s' % (i, ident(k)))


if __name__ == '__main__':
    main()
