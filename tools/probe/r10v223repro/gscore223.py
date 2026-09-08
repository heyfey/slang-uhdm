#!/usr/bin/env python3
"""§ wildcardImportCopiesPkgVarsToDefNets223 — THE GRID ARM SCORER.

For every grid arm, compares golden's and ours' instance-child CELL LISTINGS
(cells223.py's depth-keyed (owner, field, kind, name, span) rows) as ORDERED
sequences AND as order-blind MULTISETS, for the pristine and the patched run
side by side.  The multiset columns are the verdict (RESUME §9: attribute
order-blind); the ordered column names an arm whose cells are all present but
in the wrong slot.

  usage: gscore223.py <pristine-griddir> <patched-griddir> [arm ...]
"""
import os
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cells223 import scan  # noqa: E402


def rows(path):
    if not os.path.exists(path):
        return None
    out = []
    for oname, cells in scan(path):
        for f, k, nm, sp in cells:
            out.append((oname, f, k, nm, sp))
    return out


def score(g, o):
    if g is None or o is None:
        return None
    cg, co = Counter(g), Counter(o)
    miss = sum((cg - co).values())
    extra = sum((co - cg).values())
    return miss, extra, len(g), len(o), g == o


def main():
    pg, pt = sys.argv[1], sys.argv[2]
    arms = sys.argv[3:] or sorted(
        d for d in os.listdir(pg) if os.path.isdir(os.path.join(pg, d)))
    print('%-22s %-22s %-22s %s' % ('ARM', 'PRISTINE miss/extra', 'PATCHED miss/extra',
                                    'ORDERED-EQUAL pris/pat'))
    for a in arms:
        g0 = rows(os.path.join(pg, a, 'golden.dump'))
        o0 = rows(os.path.join(pg, a, 'ours.dump'))
        g1 = rows(os.path.join(pt, a, 'golden.dump'))
        o1 = rows(os.path.join(pt, a, 'ours.dump'))
        s0, s1 = score(g0, o0), score(g1, o1)
        if s0 is None or s1 is None:
            print('%-22s NO-DATABASE (rc-checked arm; see GRID.rc)' % a)
            continue
        assert g0 == g1, 'golden moved for %s — impossible' % a
        print('%-22s %-22s %-22s %s/%s' % (
            a, '%d/%d' % (s0[0], s0[1]), '%d/%d' % (s1[0], s1[1]),
            s0[4], s1[4]))


if __name__ == '__main__':
    main()
