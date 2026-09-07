#!/usr/bin/env python3
# r10v188 — SCORE A ct188cen TRIPLE ON THE JUDGED FIELDS ONLY.
# MEASUREMENT ONLY; the official uhdm-cmp is the acceptance judge.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# Identical to r10uvm188repro/score188.py except that the VALUE compared is
# DEC + SZ and NOT VAL.  Read out of the generated Compares, not guessed:
#   ~/git-repos/UHDM/build/generated/src/enum_const.cpp — VpiName, VpiDecompile,
#     VpiSize (after basetype expr::Compare)
#   ~/git-repos/UHDM/build/generated/src/expr.cpp       — VpiDecompile, VpiSize,
#     Typespec
# NO generated Compare reads an enum_const's VpiValue, so an INT:/UINT: split is
# DUMP-ONLY and cannot move the judge.  score188.py scores it anyway (which is
# the right default for a census meant to stay readable); this scorer answers
# the narrower question the acceptance gate actually asks.
#
#   usage: scorejudged188.py <golden.cen> <pristine.cen> <patched.cen>
import collections
import sys


def load(p):
    m = collections.defaultdict(list)
    with open(p) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line:
                continue
            parts = line.split('|')
            if len(parts) < 10:
                continue
            n = 1
            if parts[-1].startswith('N='):
                n = int(parts[-1][2:])
            key = '|'.join([parts[0]] + parts[2:6])
            val = '|'.join(parts[6:8])          # DEC + SZ only; VAL dropped
            m[key].extend([val] * n)
    for k in m:
        m[k].sort()
    return m


def main():
    if len(sys.argv) < 4:
        print('usage: scorejudged188.py <golden.cen> <pris.cen> <patched.cen>')
        return 2
    g, o, q = (load(x) for x in sys.argv[1:4])
    keys = sorted(set(g) | set(o) | set(q))
    tally = collections.Counter()
    for k in keys:
        gv, ov, qv = g.get(k), o.get(k), q.get(k)
        if gv is None or ov is None or qv is None:
            tally['ONE-SIDED-KEY'] += 1
            if ov != qv:
                print('ONE-SIDED-KEY-MOVED\t%s\n    gold %s\n    pris %s\n'
                      '    patched %s' % (k, gv, ov, qv))
            continue
        if ov == gv and qv == gv:
            tally['MATCH-KEPT'] += 1
        elif ov != gv and qv == gv:
            tally['TO-GOLDEN'] += 1
        elif ov == gv and qv != gv:
            tally['AWAY-GOLDEN'] += 1
            print('AWAY-GOLDEN\t%s\n    gold %s\n    patched %s' % (k, gv, qv))
        elif ov != qv:
            tally['CHANGED-STILL-WRONG'] += 1
            print('CHANGED-STILL-WRONG\t%s\n    gold %s\n    pris %s\n'
                  '    patched %s' % (k, gv, ov, qv))
        else:
            tally['WRONG-KEPT'] += 1
    print('-- JUDGED-FIELDS CELLS=%d  ' % len(keys) + '  '.join(
        '%s=%d' % (k, tally[k]) for k in
        ('MATCH-KEPT', 'TO-GOLDEN', 'AWAY-GOLDEN', 'CHANGED-STILL-WRONG',
         'WRONG-KEPT', 'ONE-SIDED-KEY')))
    bad = tally['AWAY-GOLDEN'] + tally['CHANGED-STILL-WRONG']
    print('VERDICT: %s' % ('PASS' if bad == 0 else 'FAIL'))
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
