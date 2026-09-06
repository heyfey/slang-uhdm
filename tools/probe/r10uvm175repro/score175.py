#!/usr/bin/env python3
"""r10uvm175 — score a golden / pristine / patched triple of `cells175.py`
listings as a MULTISET JOIN.  MEASUREMENT ONLY.  LHS is ALWAYS golden.

Per KEY (path start + path VpiName) the three sides hold a MULTISET of
element-shape vectors.  The SET at each key is compared, never the
multiplicity: the two producers legitimately emit different COPY COUNTS of the
same package body (r10uvm170 residue R6) and a multiplicity-sensitive score
drowns the cells a law owns.

Verdicts, per key:

  SAME_AGREE   pristine == patched == golden        (a cell that must not move)
  TOGOLD       pristine != golden, patched == golden          (the law's win)
  AWAY         pristine == golden, patched != golden          (FATAL)
  MOVEDWRONG   pristine != golden, patched != golden, and patched != pristine
  STILLWRONG   pristine == patched != golden                  (untouched residue)
  G-ONLY       key only in golden
  O-ONLY       key only in ours

TWO COLUMNS, both printed.  The default column compares the WHOLE shape,
spans included.  `--judge` strips every span and every index parent kind and
compares only what a generated `Compare` actually reads — VpiType, VpiName and
the per-kind child KINDS (RESUME.md §9: `VpiFile`/line/col and `VpiParent` are
read by no generated `Compare`, and `VpiFullName` is dump-only).  A cell that
is MOVEDWRONG in the first column and TOGOLD in the second has moved every
field the judge can see and differs only in a span; say so, never hide it.

  usage: score175.py <g.cells> <pris.cells> [<pat.cells>] <label> [--judge]
"""
import sys
import re
from collections import defaultdict

SPAN = re.compile(r'\|\d+:\d+-\d+:\d+')
IDXSPAN = re.compile(r'@\d+:\d+-\d+:\d+\^[a-z_]*')


def judgeform(v):
    return IDXSPAN.sub('@^', SPAN.sub('|', v))


def load(p, judge):
    d = defaultdict(set)
    if not p:
        return None
    try:
        fh = open(p, errors='replace')
    except OSError:
        return None
    for line in fh:
        parts = line.rstrip('\n').split('\t')
        if len(parts) < 2:
            continue
        d[parts[0]].add(judgeform(parts[1]) if judge else parts[1])
    return d


def main():
    judge = '--judge' in sys.argv
    av = [a for a in sys.argv if a != '--judge']
    g = load(av[1], judge)
    pri = load(av[2], judge)
    pat = load(av[3], judge) if len(av) > 4 and av[3] else None
    label = av[-1] + ('/judge' if judge else '')
    counts = defaultdict(int)
    detail = []
    for k in sorted(set(g) | set(pri or {}) | set(pat or {})):
        if k not in g:
            counts['O-ONLY'] += 1
            detail.append(('O-ONLY', k, '', ''))
            continue
        if k not in (pri or {}):
            counts['G-ONLY'] += 1
            detail.append(('G-ONLY', k, '', ''))
            continue
        gp, pp = g[k], pri[k]
        qq = pat[k] if pat is not None and k in pat else None
        if pat is None:
            v = 'AGREE' if gp == pp else 'DIFF'
        elif gp == pp and qq == gp:
            v = 'SAME_AGREE'
        elif gp != pp and qq == gp:
            v = 'TOGOLD'
        elif gp == pp and qq != gp:
            v = 'AWAY'
        elif qq == pp:
            v = 'STILLWRONG'
        else:
            v = 'MOVEDWRONG'
        counts[v] += 1
        if v not in ('SAME_AGREE', 'AGREE'):
            detail.append((v, k, ' || '.join(sorted(gp)),
                           ' || '.join(sorted(qq if qq is not None else pp))))
    print('%s  %s' % (label, '  '.join('%s=%d' % (k, counts[k])
                                       for k in sorted(counts))))
    for v, k, a, b in detail:
        print('    %-11s %s\n        G: %s\n        O: %s' % (v, k, a, b))


if __name__ == '__main__':
    main()
