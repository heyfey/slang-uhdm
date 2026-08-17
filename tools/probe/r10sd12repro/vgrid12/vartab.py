#!/usr/bin/env python3
# vsd12 — THE WHOLE-VARIABLE TABLE, the measure ct12grid.sh's element table
# cannot make: it joins on the ARRAY_VAR and therefore cannot see the SCALAR
# declarations.  This law's entire claim is "the element takes the class the
# SCALAR would take at that site", so the scalar twin declared beside every
# element row has to be scored too, or the law is asserted and not measured.
#
# Prints `<fullname> -> <sorted multiset of object classes>` for every
# `*_var` object in a uhdm-dump, keyed on vpiFullName ALONE (no line:col), so
# an array_var / element pair and its scalar twin land on separate keys by
# name.  A name that decompiles more than once contributes its classes once
# (set, not list) because a repeat print carries no new information.
#
#   usage: vartab.py <dump>
import re
import sys

pat = re.compile(r'\\_([a-z_]+_var): \(([^)]*)\)')
out = {}
for line in open(sys.argv[1]):
    m = pat.search(line)
    if not m:
        continue
    cls, fn = m.group(1), m.group(2)
    out.setdefault(fn, set()).add(cls)
for k in sorted(out):
    print('%s -> %s' % (k, ','.join(sorted(out[k]))))
