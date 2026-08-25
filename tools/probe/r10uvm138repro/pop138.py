#!/usr/bin/env python3
"""r10uvm138 — THE LAW'S POPULATION out of two cen138 censuses.

A cell is in the population when, at the SAME (VIEW, SITE, SPAN), one side is
a `constant` and the other is a `ref_obj` bound to an `enum_const`:

  OURS-REF   golden constant, ours ref_obj->enum_const   (this pass's target)
  OVER-FOLD  golden ref_obj->enum_const, ours constant    (must be 0, always)

and, because the span is a MACRO-SENSITIVE key (uvm's report macros give the
same reference different line:col on the two producers), the same question is
asked a SECOND time with the span dropped: per (VIEW, SITE) the KIND multisets
are compared, so a cell can never hide behind a span shift.

  usage: pop138.py <golden.cen> <ours.cen> [--all]
LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY -- the judge is the official uhdm-cmp.
"""
import sys
from collections import Counter, defaultdict


def load(p):
    span, free = defaultdict(list), defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 6 or f[0] != 'CELL':
            continue
        rec = f[4] + '\t' + f[5]
        span[(f[1], f[2], f[3])].append(rec)
        free[(f[1], f[2])].append(rec)
    return span, free


def isenum(r):
    # ANY ref_obj, bound or not.  A first cut of this predicate demanded
    # `enum_const(` in the record and MISSED two of SeqDriver's four cells:
    # inside a WILDCARD-IMPORT CLONE our `ref_obj` carries no Actual_group at
    # all, so "is it an enumerator reference" cannot be asked of the binding.
    # The join key (the SAME source span in the SAME site) is what makes the
    # two sides the same cell.
    return r.startswith('ref_obj')


def isconst(r):
    return r.startswith('constant')


def main(a):
    show = '--all' in a
    a = [x for x in a if not x.startswith('--')]
    gs, gf = load(a[0])
    os_, of = load(a[1])
    c = Counter()
    for k in sorted(set(gs) | set(os_)):
        gv, ov = sorted(gs.get(k, [])), sorted(os_.get(k, []))
        for i in range(max(len(gv), len(ov))):
            g = gv[i] if i < len(gv) else ''
            o = ov[i] if i < len(ov) else ''
            if isconst(g) and isenum(o):
                c['OURS-REF'] += 1
                print('OURS-REF   %s | %s | %s\n    G: %s\n    O: %s' % (k[0], k[1], k[2], g, o))
            elif isenum(g) and isconst(o):
                c['OVER-FOLD'] += 1
                print('OVER-FOLD  %s | %s | %s\n    G: %s\n    O: %s' % (k[0], k[1], k[2], g, o))
    # span-free control
    for k in sorted(set(gf) | set(of)):
        gk = Counter('C' if isconst(r) else ('E' if isenum(r) else '.') for r in gf.get(k, []))
        ok = Counter('C' if isconst(r) else ('E' if isenum(r) else '.') for r in of.get(k, []))
        if gk == ok:
            continue
        d = (gk['C'] - ok['C'], gk['E'] - ok['E'])
        # only the SHAPE this law can move: golden holds MORE constants and
        # ours holds MORE enum references at the same site.
        if not (d[0] > 0 and d[1] < 0):
            continue
        c['SPANFREE-SITES'] += 1
        c['SPANFREE-CELLS'] += min(d[0], -d[1])
        if show:
            print('SPANFREE   %s | %s | G(C=%d,E=%d) O(C=%d,E=%d)' %
                  (k[0], k[1], gk['C'], gk['E'], ok['C'], ok['E']))
    print('--- ' + '  '.join('%s=%d' % (x, y) for x, y in sorted(c.items())))


if __name__ == '__main__':
    main(sys.argv[1:])
