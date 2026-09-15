#!/usr/bin/env python3
"""r11u40 — pair two `rangecensus35.py` listings and score each CELL.

    cmpcensus35.py <gold.census> <ours.census> [--only <substr>]

A CELL is keyed by (VIEW, holder-chain, range loc, side) — the VIEW is in the
key, which is the whole point of this pass's census: the DEF copy of a module
and its ELABORATED copy are different cells and a law that moves one must not
be scored against the other.  The VALUE is the multiset of bound shapes+
encodings at that cell, with multiplicities.

LHS IS ALWAYS GOLDEN.  Rows print as SAME | DIFF | OURS-MISSING | GOLD-MISSING
and the tail counts them.  A cell present on ONE side only is printed and
counted, never silently passed: a census that reaches nothing must not read as
perfection.
"""
import sys
from collections import Counter


def read(p):
    out = {}
    for ln in open(p):
        if ln.startswith('--'):
            continue
        f = ln.rstrip('\n').split(None, 4)
        if len(f) < 5:
            continue
        view, chain, loc, side, rest = f
        parts = rest.rsplit(None, 2)
        enc = parts[0].strip() if len(parts) == 3 else rest.strip()
        mult = parts[2] if len(parts) == 3 else 'x?'
        out.setdefault((view, chain, loc, side), []).append((enc, mult))
    return out


def main():
    only = None
    args = sys.argv[1:]
    if '--only' in args:
        i = args.index('--only')
        only = args[i + 1]
        args = args[:i] + args[i + 2:]
    g, o = read(args[0]), read(args[1])
    keys = sorted(set(g) | set(o))
    c = Counter()
    for k in keys:
        if only and only not in k[0]:
            continue
        gv, ov = sorted(g.get(k, [])), sorted(o.get(k, []))
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
            print('%-12s %-34s %-9s %s %s\n    gold: %s\n    ours: %s'
                  % (tag, k[0][:34], k[2], k[3], k[1][:60],
                     ' | '.join('%s %s' % x for x in gv) or '<none>',
                     ' | '.join('%s %s' % x for x in ov) or '<none>'))
    print('-- SAME=%d DIFF=%d OURS-MISSING=%d GOLD-MISSING=%d' %
          (c['SAME'], c['DIFF'], c['OURS-MISSING'], c['GOLD-MISSING']))


if __name__ == '__main__':
    main()
