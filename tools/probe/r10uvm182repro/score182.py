#!/usr/bin/env python3
"""r10uvm182repro/score182.py — the ARM SCORER, three-way.

MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

  score182.py <golden.cen> <pristine.cen> <patched.cen>

Keys a cell on the element's own IDENTITY — (file, span, hier_path name,
element index/arity, element kind, element name, LISTING) — and its VALUE on
the element's `vpiActual`.  A LOCATION-ONLY key would collapse a single-file
arm into one bucket (buvm14 §5's measured correction), and a NAME-ONLY key
cannot separate the home listing's copy of a line from the clone listing's.

Verdicts, per cell:
  CONVERTED          pristine != golden, patched == golden
  OVER-FIRE          pristine == golden, patched != golden        (must be 0)
  MOVED-STILL-WRONG  pristine != golden, patched != golden, and it MOVED
  RESIDUE            pristine != golden, patched == pristine (left as found)
  SAME               pristine == golden == patched
"""
import sys
from collections import Counter


def load(path):
    m = Counter()
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
        m[(key, val)] += 1
    return m


def bykey(m):
    d = {}
    for (k, v), n in m.items():
        d.setdefault(k, Counter())[v] += n
    return d


def main():
    g, a, b = (bykey(load(p)) for p in sys.argv[1:4])
    keys = set(g) | set(a) | set(b)
    conv = over = still = resid = same = 0
    lines = []
    for k in sorted(keys):
        G, A, B = g.get(k, Counter()), a.get(k, Counter()), b.get(k, Counter())
        if G == A == B:
            same += 1
            continue
        if A != G and B == G:
            conv += 1
            lines.append('CONVERTED         %s\n    pris %s\n    gold %s' %
                         (k, dict(A), dict(G)))
        elif A == G and B != G:
            over += 1
            lines.append('OVER-FIRE         %s\n    gold %s\n    patd %s' %
                         (k, dict(G), dict(B)))
        elif A != G and B != G and A != B:
            still += 1
            lines.append('MOVED-STILL-WRONG %s\n    pris %s\n    patd %s'
                         '\n    gold %s' % (k, dict(A), dict(B), dict(G)))
        elif A != G and A == B:
            resid += 1
            lines.append('RESIDUE           %s\n    both %s\n    gold %s' %
                         (k, dict(A), dict(G)))
        else:
            same += 1
    for line in lines:
        print(line)
    print('CONVERTED=%d OVER-FIRE=%d MOVED-STILL-WRONG=%d RESIDUE=%d SAME=%d'
          % (conv, over, still, resid, same))


main()
