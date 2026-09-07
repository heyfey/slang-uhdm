#!/usr/bin/env python3
"""r10uvm182repro/cenjoin182.py — the MULTISET join for ct182cen output.

MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

Key   = (file, span, hier_path name, element index/arity, element kind,
         element name, LISTING)
Value = the element's `vpiActual` (kind + name + line) and, for a func_call
        actual, the fields `func_call::Compare` reads.

The join is a MULTISET join (Counter subtraction), not a dict lookup: the same
key legitimately occurs several times in one database (the DEF and ELAB copies
of one clone listing), and a last-writer dict silently drops all but one of
them.  Rows are classed:

  AGREE          key present both sides with the SAME value multiset entry
  DISAGREE       key present both sides, value differs
  MISSING-OURS   key only in golden
  EXTRA-OURS     key only in ours

CALIBRATION: run it golden-against-golden first; it must read 0 DISAGREE,
0 MISSING, 0 EXTRA.  A join that cannot report zero on identical inputs cannot
be trusted to report a number on different ones.
"""
import sys
from collections import Counter


def load(path):
    keys, pairs = Counter(), Counter()
    fam = Counter()
    for line in open(path):
        line = line.rstrip('\n')
        if not line or line.startswith('FC|'):
            continue
        f = line.split('|')
        if len(f) < 9:
            continue
        # THE FILE IS DELIBERATELY OUT OF THE KEY.  Our `hier_path`s carry
        # an EMPTY VpiFile (buvm14 §7's measured census trap) so ct182cen
        # inherits one from the nearest ancestor that has one, and the two
        # producers' ancestors are different objects: golden's SeqDriver key
        # reads `uvm_printer.svh` where ours reads `testbench.sv`.  Keeping
        # it made EVERY row one-sided (AGREE 8246 / MISSING 19711 / EXTRA
        # 19647 on one pair that agrees about almost everything).  No
        # generated `Compare` reads VpiFile at all, so dropping it loses the
        # judge nothing; the SPAN, the names and the LISTING stay.
        key = '|'.join([f[1], f[2], f[3], f[4], f[5], f[-1]])
        val = '|'.join([f[6], f[7]])
        keys[key] += 1
        pairs[(key, val)] += 1
        if f[5] in ('size', 'exists', 'find', 'max', 'min'):
            fam[(key, val)] += 1
    return keys, pairs, fam


def main():
    if len(sys.argv) < 3:
        sys.exit('usage: cenjoin182.py <golden.cen> <ours.cen> [--fam]')
    gk, gp, gf = load(sys.argv[1])
    ok, op, of = load(sys.argv[2])
    agree = sum((gp & op).values())
    only_g_pair = gp - op
    only_o_pair = op - gp
    # A key that exists on both sides but whose values differ is DISAGREE; a key
    # present on one side only is MISSING/EXTRA.
    dis = miss = extra = 0
    for (k, _v), n in only_g_pair.items():
        if ok[k]:
            dis += n
        else:
            miss += n
    for (k, _v), n in only_o_pair.items():
        if not gk[k]:
            extra += n
    print('AGREE %d  DISAGREE %d  MISSING-OURS %d  EXTRA-OURS %d  '
          'rows-golden %d  rows-ours %d'
          % (agree, dis, miss, extra, sum(gp.values()), sum(op.values())))
    if '--fam' in sys.argv:
        fg = gf - of
        fo = of - gf
        for (k, v), n in sorted(fg.items()):
            print('  ONLY-GOLDEN x%d %s => %s' % (n, k, v))
        for (k, v), n in sorted(fo.items()):
            print('  ONLY-OURS   x%d %s => %s' % (n, k, v))


main()
