#!/usr/bin/env python3
"""r10uvm71 -- THE IMMEDIATE FIELD SET of ONE object, one side per run.

  usage: ct71fields.py <dump> <kind> <fullname> [--span S] [--depth N]

WHY THIS INSTRUMENT EXISTS.  `uhdm-cmp` reports `LHS: <null>` in exactly two
situations (UHDM `templates/BaseClass.h`, `SafeCompare`):

  scalar form  lhs == nullptr, rhs != nullptr
               -> m_failedRhs = THE OBJECT AT THE SLOT
  vector form  lhs vector == nullptr, rhs vector non-null AND non-empty
               -> m_failedRhs = rhs_obj, i.e. THE CONTAINING OBJECT

In the vector form the object printed by the cmp is NOT the surplus entry, it is
the CONTAINER.  Reading it as an entry is what sent this pass's brief looking for
a surplus method in a class_defn vector that turned out to be identical on both
sides.  So: list the container's OWN immediate fields and diff the two sides.

A null vector and an EMPTY vector are different things to `SafeCompare` and the
dump cannot tell them apart -- it prints neither.  That asymmetry is why the
vector form fires at all, and it is why the fix is about whether a vector is
CREATED, not about what goes in it.
"""
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from dumptree import parse, is_backref   # noqa: E402

path, kind, want = sys.argv[1], sys.argv[2], sys.argv[3]
span = None
if '--span' in sys.argv:
    span = sys.argv[sys.argv.index('--span') + 1]

_roots, nodes = parse(path)
hits = [n for n in nodes
        if n.kind == kind and n.name == want and not is_backref(n)
        and (span is None or n.span == span)]
if not hits:
    print('NO FULL PRINT FOUND for %s(%s)' % (kind, want))
    sys.exit(3)
print('FULL prints: %d' % len(hits))
for n in hits:
    print('OBJECT %s(%s)@%s  dumpline=%d' % (n.kind, n.name, n.span, n.line))
    for k, v in n.fields.items():
        print('   scalar %-24s = %s' % (k, v))
    seen = []
    for f, kid in n.children:
        seen.append((f, kid.kind, kid.name, kid.span))
    for i, (f, kk, kn, ks) in enumerate(seen):
        print('   [%2d] %-20s %-16s %-46s @%s' % (i, f, kk, kn, ks))
