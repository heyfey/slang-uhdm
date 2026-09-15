#!/usr/bin/env python3
"""r11v35 (VERIFIER) — the CELL TABLE beside score35.py's counters.

    cellcmp35.py <gold.census> <pris.census> <law.census>

`score35.py` buckets a cell; this prints the cell itself — GOLD | PRIS | LAW,
one line per (range-loc, side) — so a MOVED-WRONG can be read rather than
trusted.  It is what turned the two `g4_view35` MOVED-WRONG cells (and the
same two on the verifier's own `v4_use35` / `v5_patonly35` arms) into a
statement that can be checked: golden carries BOTH shapes there (the
declaration object AND `ExprEval::flattenPatternAssignments`'s reduced clone),
we carry one, and the law swaps which of golden's shapes our copies wear —
from matching the single clone to matching the two-to-three declaration
copies.  Cells present on one side only are printed with `None`, never
dropped.
"""
import sys
from collections import defaultdict


def read(path):
    out = defaultdict(list)
    for ln in open(path):
        if ln.startswith('--') or 'no-range-bound' in ln:
            continue
        f = ln.split()
        if len(f) < 5:
            continue
        out[(f[2], f[3])].append(' '.join(f[4:]))
    return out


def main():
    g, a, b = (read(p) for p in sys.argv[1:4])
    for k in sorted(set(g) | set(a) | set(b),
                    key=lambda x: (int(x[0].split(':')[0]) if x[0][0].isdigit()
                                   else 0, x[0], x[1])):
        print('%-9s %s | GOLD %s | PRIS %s | LAW %s'
              % (k[0], k[1], g.get(k), a.get(k), b.get(k)))


if __name__ == '__main__':
    main()
