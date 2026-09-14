#!/usr/bin/env python3
"""r11u33 — THE THREE-WAY CELL SCORE.  gold x pristine x law, per cell.

    score33.py <gold.census> <pris.census> <law.census>

TO-GOLDEN   pristine != gold and law == gold
AWAY-GOLDEN pristine == gold and law != gold   <- the number that must be 0
MOVED-WRONG pristine != gold and law != gold and law != pristine
STILL-WRONG pristine == law != gold
UNMOVED     pristine == law == gold

A cell that exists on one side only is its own bucket and is printed, never
folded into UNMOVED.
"""
import sys
from collections import Counter
from cmpcensus33 import read


def main():
    g, p, l = (read(a) for a in sys.argv[1:4])
    keys = sorted(set(g) | set(p) | set(l))
    c = Counter()
    for k in keys:
        gv = tuple(sorted(g.get(k, [])))
        pv = tuple(sorted(p.get(k, [])))
        lv = tuple(sorted(l.get(k, [])))
        if gv and not pv and not lv:
            tag = 'OURS-MISSING'
        elif not gv:
            tag = 'GOLD-MISSING'
        elif pv != gv and lv == gv:
            tag = 'TO-GOLDEN'
        elif pv == gv and lv != gv:
            tag = 'AWAY-GOLDEN'
        elif pv != gv and lv != gv and lv != pv:
            tag = 'MOVED-WRONG'
        elif pv == lv and lv != gv:
            tag = 'STILL-WRONG'
        else:
            tag = 'UNMOVED'
        c[tag] += 1
        if tag in ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG'):
            print('%-12s %-10s %s %s' % (tag, k[2], k[3], k[1][:66]))
            print('    gold %s\n    pris %s\n    law  %s' %
                  (' | '.join('%s %s' % x for x in gv) or '<none>',
                   ' | '.join('%s %s' % x for x in pv) or '<none>',
                   ' | '.join('%s %s' % x for x in lv) or '<none>'))
    print('-- ' + ' '.join('%s=%d' % (t, c[t]) for t in
                           ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG',
                            'STILL-WRONG', 'UNMOVED', 'OURS-MISSING',
                            'GOLD-MISSING')))


if __name__ == '__main__':
    main()
