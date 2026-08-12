#!/usr/bin/env python3
"""r10earl31 — the per-CELL table: every constant at a chosen POSITION, both
sides, in source order, with its typespec.  golden is ALWAYS argv[1].

    usage: cells31.py <golden.dump> <ours.dump> [POSITION-substring ...]

Unlike census31.py this prints EVERY cell, not a sample: a grid claim needs the
whole column or it is an anecdote.  Multiplicity is kept — two constants at the
same start span (def + elab views, or two instances) print as two rows.
"""
import sys
from collections import defaultdict

import tsread
from census31 import position, stmtkind


def rows(path):
    out = []
    for c in tsread.parse(path):
        if c.stub:
            continue
        pos, ops = position(c)
        out.append((pos, c.sspan, ops, stmtkind(c), c.span,
                    c.fields.get('vpiDecompile', ''), c.fields.get('VALUE', ''),
                    c.fields.get('vpiSize', ''), c.fields.get('vpiConstType', ''),
                    tsread.ts_of(c), tsread.named_ancestor(c)))
    return out


def lineno(sspan):
    try:
        return int(sspan.split(':')[0]), int(sspan.split(':')[1])
    except Exception:
        return (0, 0)


def main():
    g, o = rows(sys.argv[1]), rows(sys.argv[2])
    want = sys.argv[3:]
    def keep(r):
        return not want or any(w in r[0] for w in want)
    gg = defaultdict(list)
    for r in g:
        if keep(r):
            gg[(r[0], r[1], r[5])].append(r)
    oo = defaultdict(list)
    for r in o:
        if keep(r):
            oo[(r[0], r[1], r[5])].append(r)
    keys = sorted(set(gg) | set(oo), key=lambda k: (lineno(k[1]), k[0], k[2]))
    print('%-9s %-30s %-4s %-11s %-7s %s' %
          ('start', 'POSITION', 'ops', 'stmt', 'side', 'ts / <bare>   [n]'))
    for k in keys:
        for side, tab in (('GOLDEN', gg), ('ours', oo)):
            rs = tab.get(k, [])
            if not rs:
                print('%-9s %-30s %-4s %-11s %-7s %s' %
                      (k[1], k[0], '-', '-', side, '*** NO SUCH CONSTANT ***'))
                continue
            for r in rs:
                print('%-9s %-30s %-4s %-11s %-7s %s   [%s sz=%s ct=%s span=%s]' %
                      (r[1], r[0], r[2], r[3], side, r[9] or '<bare>',
                       r[6], r[7], r[8], r[4]))
        print()


if __name__ == '__main__':
    main()
