#!/usr/bin/env python3
"""r10uvm121 — multiset join of two ct121cen censuses.

MEASUREMENT ONLY; the official uhdm-cmp is the judge.  GOLDEN IS ALWAYS THE
FIRST ARGUMENT.

Cell key   = (view, top, home, span)      — the judge-visible slot
Cell value = (Rhs, Lhs)                   — what the slot holds

Verdicts, one-sided sets FIRST (uvm109's lesson: a pass that REMOVES objects
must score one-sided sets explicitly, so an object we have and golden does not
can never hide inside a "DIFF"):

  ONLY-G      cell present only in golden           (we emit no assignment there)
  ONLY-O      cell present only in ours             (a SURPLUS assignment)
  EMPTY-BOTH  both sides <null>/<null>
  OURS-FULL   golden <null>/<null>, ours holds something   <- THE HEAD FAMILY
  GOLD-FULL   ours <null>/<null>, golden holds something
  DIFF        both non-empty and different
  SAME        identical values
"""
import sys, collections

def load(p):
    c = collections.Counter()
    for line in open(p, errors='replace'):
        f = line.rstrip('\n').split('\t')
        if len(f) != 6: continue
        c[(f[0], f[1], f[2], f[3], f[4], f[5])] += 1
    return c

def bycell(c):
    d = collections.defaultdict(collections.Counter)
    for k, n in c.items():
        d[k[:4]][k[4:]] += n
    return d

def main(gp, op, verbose=False):
    g, o = bycell(load(gp)), bycell(load(op))
    tot = collections.Counter()
    rows = []
    for cell in set(g) | set(o):
        gv, ov = g.get(cell, collections.Counter()), o.get(cell, collections.Counter())
        if not ov:
            tot['ONLY-G'] += sum(gv.values()); rows.append(('ONLY-G', cell, gv, ov)); continue
        if not gv:
            tot['ONLY-O'] += sum(ov.values()); rows.append(('ONLY-O', cell, gv, ov)); continue
        # multiset difference inside the cell
        common = gv & ov
        gr, orr = gv - common, ov - common
        for v, n in common.items():
            tot['EMPTY-BOTH' if v == ('<null>', '<null>') else 'SAME'] += n
        NUL = ('<null>', '<null>')
        gn, on = gr.get(NUL, 0), orr.get(NUL, 0)
        m = min(gn, sum(orr.values()) - on)
        # golden empty facing a non-empty of ours
        k = min(gn, sum(v for x, v in orr.items() if x != NUL))
        if k:
            tot['OURS-FULL'] += k; rows.append(('OURS-FULL', cell, gr, orr))
            gn -= k
        k2 = min(on, sum(v for x, v in gr.items() if x != NUL))
        if k2:
            tot['GOLD-FULL'] += k2; rows.append(('GOLD-FULL', cell, gr, orr))
        rest = sum(gr.values()) - min(gr.get(NUL,0), sum(orr.values()))
        d = min(sum(v for x,v in gr.items() if x != NUL) - k2,
                sum(v for x,v in orr.items() if x != NUL) - k)
        if d > 0:
            tot['DIFF'] += d; rows.append(('DIFF', cell, gr, orr))
    for k in ('SAME','EMPTY-BOTH','OURS-FULL','GOLD-FULL','DIFF','ONLY-G','ONLY-O'):
        print('%-11s %d' % (k, tot[k]))
    if verbose:
        for tag, cell, gv, ov in sorted(rows):
            if tag in ('SAME','EMPTY-BOTH'): continue
            print('%-10s %s' % (tag, ' | '.join(cell)))
            print('           G=%s' % dict(gv))
            print('           O=%s' % dict(ov))

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], '-v' in sys.argv[3:])
