#!/usr/bin/env python3
"""r10uvm71 -- WHERE DOES THIS OBJECT HANG?  One side per run.

  usage: ct71where.py <dump> <kind> <fullname>

The pass's brief asserted the head was a surplus entry in the class_defn's
task_func vector.  `ct71census.py` REFUTED that (both sides' vpiMethod vectors
are 32 entries, same names, same order).  So before any more theorising, this
instrument simply ENUMERATES every print of the object in the dump and reports,
for each, the FIELD LABEL it hangs on and its PARENT -- full prints and
back-references separately.  Two sides diffed on this output say exactly which
container disagrees.

TRAPS: `sed 1d` dumps (first line is the db path); an object is not a dump
occurrence -- a childless print is a back-reference and is labelled as such.
"""
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from dumptree import parse, is_backref   # noqa: E402

path, kind, want = sys.argv[1], sys.argv[2], sys.argv[3]
_roots, nodes = parse(path)

full = back = 0
for n in nodes:
    if n.kind != kind or n.name != want:
        continue
    par = n.parent
    label = ''
    if par is not None:
        for f, k in par.children:
            if k is n:
                label = f
                break
    tag = 'BACKREF' if is_backref(n) else 'FULL   '
    if is_backref(n):
        back += 1
    else:
        full += 1
    print('%s line=%-9d field=%-18s parent=%s(%s)@%s' %
          (tag, n.line, label or '<root>',
           par.kind if par else '-', par.name if par else '-',
           par.span if par else '-'))
print('-- FULL prints=%d  BACKREF prints=%d' % (full, back))
