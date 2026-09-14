#!/usr/bin/env python3
"""r11u33 — pair two rangecensus33 listings and score each CELL.

    cmpcensus33.py <gold.census> <ours.census>

A CELL is keyed by (view, holder-chain, range loc, side); the VALUE is the
bound's shape+encoding.  LHS IS ALWAYS GOLDEN.  Rows print as

    SAME | DIFF | GOLD-ONLY | OURS-ONLY

and the tail counts them.  A cell present on one side only is NOT a silent
pass: it is printed and counted, because a census that reaches nothing must
never read as perfection.
"""
import sys
from collections import Counter


def read(p):
    out = {}
    for ln in open(p):
        if ln.startswith('--'):
            continue
        f = ln.rstrip('\n').split(None, 3)
        if len(f) < 4:
            continue
        view, chain, loc, rest = f
        side = rest[:1]
        rest = rest[2:]
        # trailing "<bloc>  xN"
        parts = rest.rsplit(None, 2)
        enc = parts[0].strip() if len(parts) == 3 else rest.strip()
        mult = parts[2] if len(parts) == 3 else 'x?'
        out.setdefault((view, chain, loc, side), []).append((enc, mult))
    return out


def main():
    g, o = read(sys.argv[1]), read(sys.argv[2])
    keys = sorted(set(g) | set(o))
    c = Counter()
    for k in keys:
        gv = sorted(g.get(k, []))
        ov = sorted(o.get(k, []))
        if k not in o:
            tag = 'OURS-MISSING'
        elif k not in g:
            tag = 'GOLD-MISSING'
        elif gv == ov:
            tag = 'SAME'
        else:
            tag = 'DIFF'
        c[tag] += 1
        if tag != 'SAME':
            print('%-12s %-10s %s %s\n    gold: %s\n    ours: %s'
                  % (tag, k[2], k[3], k[1][:70],
                     ' | '.join('%s %s' % x for x in gv) or '<none>',
                     ' | '.join('%s %s' % x for x in ov) or '<none>'))
    print('-- SAME=%d DIFF=%d OURS-MISSING=%d GOLD-MISSING=%d' %
          (c['SAME'], c['DIFF'], c['OURS-MISSING'], c['GOLD-MISSING']))


if __name__ == '__main__':
    main()
