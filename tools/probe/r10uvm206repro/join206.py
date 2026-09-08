#!/usr/bin/env python3
"""r10uvm206 — join206.py — MEASUREMENT ONLY.  The official uhdm-cmp is the
sole judge; this joins two ct206cen censuses.  LHS is ALWAYS golden.

Cells are `<key>\t<value>` and the join is on the KEY (a listing position or an
array_var face), so the score separates

  AGREE        the key exists on both sides with the same identity
  TS-DIFF      the key exists on both sides with a DIFFERENT identity
  ONLY-GOLDEN  golden has the key and we do not
  ONLY-OURS    we have the key and golden does not   (AWAY-GOLDEN when it rises)

A MULTISET join, not a dict: a key may repeat (two package views can hold the
same listing position), and a last-writer dict would silently drop rows.

  usage: join206.py <golden.cells> <ours.cells> [--diffs]
"""
import sys
from collections import Counter, defaultdict


def load(p):
    m = defaultdict(list)
    for line in open(p):
        line = line.rstrip('\n')
        if '\t' not in line:
            continue
        k, v = line.split('\t', 1)
        m[k].append(v)
    for k in m:
        m[k].sort()
    return m


def main():
    g = load(sys.argv[1])
    o = load(sys.argv[2])
    diffs = '--diffs' in sys.argv[3:]
    agree = tsdiff = onlyg = onlyo = 0
    for k in set(g) | set(o):
        cg, co = Counter(g.get(k, [])), Counter(o.get(k, []))
        both = cg & co
        agree += sum(both.values())
        rg, ro = cg - co, co - cg
        pair = min(sum(rg.values()), sum(ro.values()))
        tsdiff += pair
        onlyg += sum(rg.values()) - pair
        onlyo += sum(ro.values()) - pair
        if diffs and (rg or ro):
            for v in sorted(rg.elements()):
                print('G %s\t%s' % (k, v))
            for v in sorted(ro.elements()):
                print('O %s\t%s' % (k, v))
    if not diffs:
        print('AGREE=%d TS-DIFF=%d ONLY-GOLDEN=%d ONLY-OURS=%d'
              % (agree, tsdiff, onlyg, onlyo))


main()
