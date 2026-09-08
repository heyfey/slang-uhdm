#!/usr/bin/env python3
"""r10uvm219 — the MATERIALIZED-LISTING census join.  MEASUREMENT ONLY; the
official uhdm-cmp is the sole judge.  LHS is ALWAYS golden, RHS is ALWAYS ours.

Two faces per listing cell (`<view>|<inst key>|nets` or `…|vars`), because the
judge is POSITIONAL and the two failure modes are different:

  * POSITION   — element i of golden against element i of ours.  This is what
    `BaseClass::SafeCompare`'s vector overload does (`BaseClass.h:200-224`)
    and, since `nets::Compare` (generated `nets.cpp`) compares `VpiName`, a
    PERMUTATION of a net listing is NOT judge-invisible.  Cells: AGREE,
    POSDIFF, ONLY-GOLDEN (golden longer), ONLY-OURS (we are longer).
  * MULTISET   — the same two vectors as COUNTED bags, which separates a
    MISSING block (bags differ) from a MISORDERED one (bags equal, positions
    not).  Counted, never a dict: an import copy legitimately repeats a face.

Usage: cen219.py <golden.cen> <ours.cen>
Exit status is always 0; the last line is the machine-readable summary.
"""
import sys
from collections import Counter, defaultdict


def load(path):
    """cell key -> ordered list of element faces."""
    cells = defaultdict(list)
    arity = {}
    for line in open(path, 'rt', errors='replace'):
        f = line.rstrip('\n').split('|')
        if f[0] == 'ARITY' and len(f) >= 6:
            arity[(f[1], f[2], f[3])] = (f[4], f[5])
            cells.setdefault((f[1], f[2], f[3]), [])
        elif f[0] in ('NET', 'VAR') and len(f) >= 6:
            vec = 'nets' if f[0] == 'NET' else 'vars'
            cells[(f[1], f[2], vec)].append((int(f[3]), '|'.join(f[4:])))
    out = {}
    for k, v in cells.items():
        v.sort()
        out[k] = [x[1] for x in v]
    return out, arity


def main():
    if len(sys.argv) < 3:
        print('usage: cen219.py <golden.cen> <ours.cen>')
        return 0
    G, GA = load(sys.argv[1])
    O, OA = load(sys.argv[2])
    keys = sorted(set(G) | set(O))
    agree = posdiff = onlyg = onlyo = 0
    bagg = bago = 0
    misordered = 0
    for k in keys:
        g = G.get(k, [])
        o = O.get(k, [])
        n = min(len(g), len(o))
        a = p = 0
        for i in range(n):
            if g[i] == o[i]:
                a += 1
            else:
                p += 1
                print('POSDIFF|%s|%s|%s|%d|G=%s|O=%s' % (k[0], k[1], k[2], i,
                                                         g[i], o[i]))
        for i in range(n, len(g)):
            print('ONLY-GOLDEN|%s|%s|%s|%d|%s' % (k[0], k[1], k[2], i, g[i]))
        for i in range(n, len(o)):
            print('ONLY-OURS|%s|%s|%s|%d|%s' % (k[0], k[1], k[2], i, o[i]))
        agree += a
        posdiff += p
        onlyg += len(g) - n
        onlyo += len(o) - n
        cg, co = Counter(g), Counter(o)
        bg = sum((cg - co).values())
        bo = sum((co - cg).values())
        bagg += bg
        bago += bo
        if bg == 0 and bo == 0 and p:
            misordered += 1
            print('MISORDERED-ONLY|%s|%s|%s|len=%d' % (k[0], k[1], k[2], len(g)))
        if len(g) != len(o) or p:
            print('CELL|%s|%s|%s|G=%d|O=%d|AGREE=%d|POSDIFF=%d|BAG-G=%d|BAG-O=%d'
                  % (k[0], k[1], k[2], len(g), len(o), a, p, bg, bo))
    print('-- CELLS=%d AGREE=%d POSDIFF=%d ONLY-GOLDEN=%d ONLY-OURS=%d '
          'BAG-ONLY-GOLDEN=%d BAG-ONLY-OURS=%d MISORDERED-CELLS=%d'
          % (len(keys), agree, posdiff, onlyg, onlyo, bagg, bago, misordered))
    return 0


if __name__ == '__main__':
    sys.exit(main())
