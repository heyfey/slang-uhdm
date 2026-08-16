#!/usr/bin/env python3
"""r10sd6 — WHERE DOES THE FAILING OBJECT HANG?

The cmp head names an object; it does NOT name the SLOT the comparison was
standing in when it failed.  On a design the size of SeqDriver that slot is the
whole question: the same `class_var` is printed 12 times on one side and 15 on
the other, and only the CONTAINER tells you which of those prints is the defect.

This walks a `sed 1d` uhdm-dump with dumptree.py and prints, for every FULL
print (not a back-reference) of an object matching a kind/name filter, the
ancestor PATH as `kind(name)/field->kind(name)/...` — so the two sides' path
MULTISETS can be diffed directly.

GUARDS:
  * back-references (childless prints) are counted SEPARATELY and never mixed
    into the full-print census — "an object is not a dump occurrence";
  * a filter that matches NOTHING prints NO-MATCH and exits 4, so an empty
    census cannot read as agreement.

usage: ct6path.py <dump> <kind-regex> <name-regex>
"""
import re
import sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import dumptree

# BACKREFS=1 also prints the CHILDLESS prints (vpiActual / vpiParent
# back-references).  They are the half of the census that a 'full prints only'
# reading is blind to, and this pass's defect lives in exactly that half.
import os
BACKREFS = os.environ.get('BACKREFS', '0') == '1'


def path_of(n, depth=8):
    out = []
    cur = n
    while cur is not None and len(out) < depth:
        lbl = ''
        if cur.parent is not None:
            for f, k in cur.parent.children:
                if k is cur:
                    lbl = f
                    break
        out.append('%s%s(%s)' % (lbl + '->' if lbl else '', cur.kind, cur.name))
        cur = cur.parent
    return ' / '.join(reversed(out))


def main():
    dump, kre, nre = sys.argv[1], re.compile(sys.argv[2]), re.compile(sys.argv[3])
    roots, nodes = dumptree.parse(dump)
    full, back = [], 0
    for n in nodes:
        if not kre.search(n.kind) or not nre.search(n.name):
            continue
        if dumptree.is_backref(n):
            back += 1
            if BACKREFS:
                print('BACK  %s  @%s' % (path_of(n), n.span))
            continue
        full.append(n)
    if not full and not back:
        print('NO-MATCH kind=%s name=%s in %s' % (sys.argv[2], sys.argv[3], dump))
        sys.exit(4)
    for n in full:
        print('FULL  %s  @%s' % (path_of(n), n.span))
    print('-- full prints=%d  back-references=%d' % (len(full), back))


main()
