#!/usr/bin/env python3
"""r10uvm203 — the census join.  MEASUREMENT ONLY.

Reads the two cell files ct203cen produces for ONE database pair (golden, ours)
and reports AGREE / DIFF / ONLY-GOLDEN / ONLY-OURS as MULTISETS (a dict would
drop colliding rows -- RESUME §9).  LHS is ALWAYS golden.

usage: cen203.py <golden.cells> <ours.cells> [--diffs]
"""
import sys
from collections import Counter

def load(p):
    c = Counter()
    with open(p) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line:
                continue
            k, _, v = line.rpartition('\t')
            c[(k, v)] += 1
    return c

def keys(c):
    k = Counter()
    for (kk, vv), n in c.items():
        k[kk] += n
    return k

def main():
    g = load(sys.argv[1])
    o = load(sys.argv[2])
    show = '--diffs' in sys.argv[3:]
    gk, ok = keys(g), keys(o)
    only_g = gk - ok
    only_o = ok - gk
    common = gk & ok
    agree = 0
    diff = 0
    difflines = []
    # per key, compare the payload multisets
    gp, op = {}, {}
    for (kk, vv), n in g.items():
        gp.setdefault(kk, Counter())[vv] += n
    for (kk, vv), n in o.items():
        op.setdefault(kk, Counter())[vv] += n
    for kk, n in common.items():
        a = gp[kk]
        b = op[kk]
        same = sum((a & b).values())
        agree += same
        d = n - same
        if d > 0:
            diff += d
            difflines.append('DIFF\t%s\tG=%s\tO=%s' % (kk, dict(a), dict(b)))
    print('AGREE=%d TS-DIFF=%d ONLY-GOLDEN=%d ONLY-OURS=%d GCELLS=%d OCELLS=%d' %
          (agree, diff, sum(only_g.values()), sum(only_o.values()),
           sum(gk.values()), sum(ok.values())))
    if show:
        for l in difflines:
            print(l)
        for kk, n in sorted(only_g.items()):
            print('ONLY-GOLDEN\t%s\tx%d\t%s' % (kk, n, dict(gp[kk])))
        for kk, n in sorted(only_o.items()):
            print('ONLY-OURS\t%s\tx%d\t%s' % (kk, n, dict(op[kk])))

main()
