#!/usr/bin/env python3
"""r10sd1 — SLOT CENSUS: every place a named object appears in a dump, keyed by
(enclosing object, field label).

The r10uvm52-era law says a `RHS: <null>` head names a SLOT.  When the parent
VECTOR censuses EQUAL on both sides (as `work@top_tb`'s 125-entry Typespecs
does here) the missing slot is a SINGULAR field somewhere else, and the only way
to find it is to enumerate every slot the object occupies on each side and
difference the two multisets.

    usage: slots.py <dump> <object-line-regex>

Prints `<enclosing kind> (<enclosing name>) . <label>` for each occurrence, then
a count per distinct slot shape, sorted.

GUARD: zero matches is exit 4 -- an empty slot census reads exactly like "the
object does not appear", which is the finding this script exists to distinguish
from a broken regex.
"""
import re
import sys
from collections import Counter

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): ?(.*)$')
LBL = re.compile(r'^(\s*)\|([A-Za-z0-9_]+):')

def main():
    dump, rx = sys.argv[1], re.compile(sys.argv[2])
    lines = open(dump, errors='replace').read().split('\n')
    # stack[indent] = (kind, name) of the object opened at that indent
    hits = 0
    c = Counter()
    stack = {}
    for i, l in enumerate(lines):
        om = OBJ.match(l)
        if om:
            ind = len(om.group(1))
            nm = re.match(r'^(?:[^(]*)\(([^)]*)\)', om.group(3))
            stack[ind] = (om.group(2), nm.group(1) if nm else '')
            if rx.search(l):
                hits += 1
                lbl = ''
                if i > 0:
                    lm = LBL.match(lines[i - 1])
                    if lm:
                        lbl = lm.group(2)
                par = stack.get(ind - 2, ('<ROOT>', ''))
                c['%s (%s) . %s' % (par[0], par[1], lbl)] += 1
    if not hits:
        print('FATAL: object-regex matched nothing', file=sys.stderr)
        sys.exit(4)
    for k, n in sorted(c.items()):
        print('%5d  %s' % (n, k))
    print('TOTAL %d occurrences in %d distinct slot shapes' % (hits, len(c)))

main()
