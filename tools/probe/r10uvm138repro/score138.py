#!/usr/bin/env python3
"""r10uvm138 — join two cen138 censuses (GOLDEN first, OURS second) on
(VIEW, SITE, SPAN) as a MULTISET and score every cell.

  TOGOLD / MOVED-WRONG / AWAY / SAME-WRONG / SAME-OK, plus the ONE-SIDED sets
  in BOTH directions (a multiset join DROPS unmatched rows; a census that does
  not print them is lying about its coverage).

  usage: score138.py <golden.cen> <ours.cen> [<pristine.cen>]
     with 3 files:  golden vs OURS-PATCHED, scored against OURS-PRISTINE:
        TOGOLD      pristine != golden, patched == golden
        MOVED-WRONG pristine == golden, patched != golden   (must be 0)
        AWAY        pristine != golden, patched != golden, patched != pristine
        SAME-WRONG  pristine == patched != golden
        SAME-OK     pristine == patched == golden
LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY -- the judge is the official uhdm-cmp.
"""
import sys
from collections import Counter, defaultdict


def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 6 or f[0] != 'CELL':
            continue
        d[(f[1], f[2], f[3])].append(f[4] + '\t' + f[5])
    return d


def main(argv):
    g = load(argv[0])
    o = load(argv[1])
    p = load(argv[2]) if len(argv) > 2 else None
    keys = sorted(set(g) | set(o))
    counts = Counter()
    rows = []
    for k in keys:
        gv, ov = sorted(g.get(k, [])), sorted(o.get(k, []))
        if not gv:
            counts['ONLY-OURS'] += len(ov)
            rows.append(('ONLY-OURS', k, '-', ov))
            continue
        if not ov:
            counts['ONLY-GOLDEN'] += len(gv)
            rows.append(('ONLY-GOLDEN', k, gv, '-'))
            continue
        n = max(len(gv), len(ov))
        for i in range(n):
            a = gv[i] if i < len(gv) else '<none>'
            b = ov[i] if i < len(ov) else '<none>'
            pv = None
            if p is not None:
                pl = sorted(p.get(k, []))
                pv = pl[i] if i < len(pl) else '<none>'
            if p is None:
                tag = 'SAME-OK' if a == b else 'DIFF'
            elif pv == a and b == a:
                tag = 'SAME-OK'
            elif pv != a and b == a:
                tag = 'TOGOLD'
            elif pv == a and b != a:
                tag = 'MOVED-WRONG'
            elif pv == b:
                tag = 'SAME-WRONG'
            else:
                tag = 'AWAY'
            counts[tag] += 1
            if tag != 'SAME-OK':
                rows.append((tag, k, a, b if p is None else '%s <- %s' % (b, pv)))
    for t, k, a, b in rows:
        print('%-12s %s | %s | %s\n    G: %s\n    O: %s' % (t, k[0], k[1], k[2], a, b))
    print('--- ' + '  '.join('%s=%d' % (k, v) for k, v in sorted(counts.items())))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
