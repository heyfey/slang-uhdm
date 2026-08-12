#!/usr/bin/env python3
"""r10earl30 THE CELL TABLE — every `constant` in a dump, keyed on its SPAN,
with its OWN-CHILD fields only.  golden is ALWAYS argv[1], ours ALWAYS argv[2].

  usage: cells30.py <golden.dump> <ours.dump> [all]

MULTIPLICITY IS KEPT: the same span can carry several constants (def view + elab
view, or several instances).  A cell is (span -> sorted list of field-tuples) and
the count is printed, so a shared object and two distinct objects never read the
same.  A span present on one side only prints GOLDEN-ONLY / OURS-ONLY, never
silently.

Field reading is delegated to dumpread.own_fields — read its header for the
own-child-depth defect this instrument was caught with (a `vpiConstType` sitting
AFTER a nested `ref_typespec` was read as ABSENT, which faked an over-fire).
"""
import re
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from dumpread import objects  # noqa: E402

KEEP = ['vpiConstType', 'vpiSize', 'vpiDecompile']


def read(path):
    cells = {}
    for span, name, f, vpfx, vtxt in objects(path, 'constant'):
        tup = tuple(f.get(k, '-') for k in KEEP) + \
            ((vpfx + ':' + vtxt) if vpfx else '-',)
        cells.setdefault(span, []).append((name, tup))
    return cells


def fmt(lst):
    return ' ; '.join('%s{ct=%s sz=%s dc=%s v=%s}' % (n or '', *t)
                      for n, t in sorted(lst))


def main():
    g, o = read(sys.argv[1]), read(sys.argv[2])
    show_all = len(sys.argv) > 3 and sys.argv[3] == 'all'
    spans = sorted(set(g) | set(o),
                   key=lambda s: [int(x) for x in re.findall(r'\d+', s)] or [0])
    same = diff = 0
    for s in spans:
        gl, ol = sorted(g.get(s, [])), sorted(o.get(s, []))
        if gl == ol:
            same += 1
            if show_all:
                print('SAME     %-18s %s' % (s, fmt(gl)))
            continue
        diff += 1
        tag = ('GOLDEN-ONLY' if not ol else 'OURS-ONLY' if not gl else 'DIFFER')
        print('%-11s %-18s' % (tag, s))
        print('    G x%d %s' % (len(gl), fmt(gl)))
        print('    O x%d %s' % (len(ol), fmt(ol)))
    print('---- constant cells: %d SAME, %d DIFFER (golden spans %d, ours %d)'
          % (same, diff, len(g), len(o)))


if __name__ == '__main__':
    main()
