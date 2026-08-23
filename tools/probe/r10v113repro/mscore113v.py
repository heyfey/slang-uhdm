#!/usr/bin/env python3
"""r10v113 mscore113v.py — MULTISET cell scorer.  score113.py pairs the sorted
callee lists ELEMENTWISE, which manufactures CHANGED-STILL-WRONG pairs wherever
our emitter puts TWO objects in a cell that golden fills with one (the ELAB
class copies).  This scorer asks the only question that matters instead:

    does the PATCHED multiset agree with golden on FEWER slots than the
    PRISTINE one did?   |G & Q| < |G & P|  ==>  REGRESSION.

usage: mscore113v.py <golden.tsv> <pristine.tsv> <patched.tsv> [tag]
"""
import sys, collections

def load(path):
    d = collections.defaultdict(collections.Counter)
    for ln in open(path):
        p = ln.rstrip('\n').split('\t')
        if len(p) != 7: continue
        view, top, home, call, sp, kind, callee = p
        if callee != '<null>':
            k, _, r = callee.partition('|'); nm, _, r2 = r.partition('|')
            par, _, _l = r2.partition('@'); callee = '%s|%s|%s' % (k, nm, par)
        d[(view, top, home, call, kind)][callee] += 1
    return d

def main():
    g, p, q = (load(a) for a in sys.argv[1:4])
    tag = sys.argv[4] if len(sys.argv) > 4 else ''
    better = worse = same = 0
    for k in sorted(set(g) | set(p) | set(q)):
        gv, pv, qv = g.get(k, collections.Counter()), p.get(k, collections.Counter()), q.get(k, collections.Counter())
        ip = sum((gv & pv).values()); iq = sum((gv & qv).values())
        if iq > ip:
            better += 1
        elif iq < ip:
            worse += 1
            print('REGRESSION\t%s\tG=%s\tPRIS=%s\tPAT=%s' % ('\t'.join(k), dict(gv), dict(pv), dict(qv)))
        else:
            same += 1
    print('MSCORE %s  CELLS-BETTER=%d  CELLS-WORSE=%d  CELLS-UNCHANGED=%d' % (tag, better, worse, same))

main()
