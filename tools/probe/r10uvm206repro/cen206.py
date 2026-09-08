#!/usr/bin/env python3
"""r10uvm206 — cen206.py — MEASUREMENT ONLY.  The official uhdm-cmp is the sole
judge; this joins two ct206ts listings of the DESIGN's `vpiTypespec` vector.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

The vector overload of BaseClass::SafeCompare walks lhs->at(i) against
rhs->at(i) after a size check, so the join is POSITIONAL and the score reports
both faces:

  AGREE        indices where both sides hold the same judge-visible identity
  TS-DIFF      indices both sides hold, with a DIFFERENT identity
  ONLY-GOLDEN  indices golden holds and we do not (golden's vector is longer)
  ONLY-OURS    indices we hold and golden does not
  SET-ONLY-G / SET-ONLY-O   the same one-sided sets computed as MULTISETS,
                            which separates "missing" from "present, misplaced"

The identity is kind|name|instance-face|typedef-alias-face.  The SPAN is
deliberately NOT part of it: no generated Compare reads VpiLineNo/VpiColumnNo
(RESUME §9), so a span difference is a dump-text residue and never a head.

  usage: cen206.py <golden.ts> <ours.ts> [--diffs]
"""
import sys
from collections import Counter


def load(p):
    out = []
    for line in open(p):
        if not line.startswith('TS '):
            continue
        rest = line[3:].rstrip('\n')
        idx = int(rest[:5])
        f = rest[6:].split('|')
        if len(f) < 5:
            continue
        # kind | name | span | instance | alias   (span dropped: not compared)
        out.append((idx, f[0] + '|' + f[1] + '|' + f[3] + '|' + f[4]))
    out.sort()
    return [c for _, c in out]


def main():
    g = load(sys.argv[1])
    o = load(sys.argv[2])
    diffs = '--diffs' in sys.argv[3:]
    n = min(len(g), len(o))
    agree = sum(1 for i in range(n) if g[i] == o[i])
    tsdiff = n - agree
    onlyg = max(0, len(g) - len(o))
    onlyo = max(0, len(o) - len(g))
    cg, co = Counter(g), Counter(o)
    setg = sum((cg - co).values())
    seto = sum((co - cg).values())
    if diffs:
        for i in range(n):
            if g[i] != o[i]:
                print('POS %d G=%s O=%s' % (i, g[i], o[i]))
        for i in range(n, len(g)):
            print('POS %d G=%s O=<none>' % (i, g[i]))
        for i in range(n, len(o)):
            print('POS %d G=<none> O=%s' % (i, o[i]))
        for k in (cg - co):
            print('SETG %s x%d' % (k, (cg - co)[k]))
        for k in (co - cg):
            print('SETO %s x%d' % (k, (co - cg)[k]))
        return
    print('AGREE=%d TS-DIFF=%d ONLY-GOLDEN=%d ONLY-OURS=%d SET-ONLY-G=%d '
          'SET-ONLY-O=%d GLEN=%d OLEN=%d'
          % (agree, tsdiff, onlyg, onlyo, setg, seto, len(g), len(o)))


main()
