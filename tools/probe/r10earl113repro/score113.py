#!/usr/bin/env python3
# r10earl113 -- THE THREE-WAY ARM SCORER over the PX grid family.
#
# MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
# LHS is ALWAYS golden; RHS is ALWAYS ours.
#
# THE SCORING UNIT IS THE PX CELL, whose key already carries the operand-0
# KIND (cen113.cpp): one span legitimately holds SEVERAL operand-0 objects at
# once -- golden's arena keeps the flattened operation AND the un-flattened
# `tagged_pattern` original side by side -- so a key that did not separate them
# could never reach equality and would score every fixed cell MOVEDWRONG.  With
# the kind in the key the payload is exactly the field this law writes.
#
# Payload SETS, not multisets: the 3x arena-copy multiplicity is invisible to
# every generated Compare (earl111/earl112's precedent) and must not
# manufacture a verdict.
#
#   TOGOLD        pristine != golden, patched == golden        (the law works)
#   AWAY          pristine == golden, patched != golden        (MUST BE 0)
#   MOVEDWRONG    pristine != golden, patched != golden, moved (MUST BE 0)
#   STILLWRONG    pristine != golden, patched == pristine      (untouched, wrong)
#   SAME_AGREE    pristine == golden == patched                (untouched, right)
#   NOGOLD        golden has NO operand of this kind here      (named, counted)
#   ONESIDED      ours has none where golden does              (named, counted)
#
# earl45's lesson is why NOGOLD is its own column and is NAMED: a stamp landing
# on an object golden does not have is neither toward nor away, and folding it
# into either column would be a lie in whichever direction suited the pass.
#
#   usage: score113.py <armdir> [<armdir> ...]
import os
import sys


def load(path):
    """PX key -> set of payloads (the key already carries the operand kind)."""
    if not os.path.exists(path):
        return None
    out = {}
    for line in open(path):
        if '|PX|' not in line:
            continue
        p = line.rstrip('\n').split('\t')
        if len(p) < 3:
            continue
        out.setdefault(p[0], set()).add(p[1])
    return out


def main(argv):
    tot = {}
    bad = []
    for arm in argv:
        g = load(os.path.join(arm, 'cen.gold.txt'))
        p = load(os.path.join(arm, 'cen.pris.txt'))
        q = load(os.path.join(arm, 'cen.patch.txt'))
        if g is None or p is None or q is None:
            print('MISSING CENSUS in %s' % arm)
            return 2
        c = {}
        for k in sorted(set(g) | set(p) | set(q)):
            gg, pp, qq = g.get(k), p.get(k), q.get(k)
            if gg is None:
                v = 'NOGOLD' if pp != qq else 'NOGOLD_UNMOVED'
            elif pp is None and qq is None:
                v = 'ONESIDED'
            elif pp is None or qq is None:
                v = 'ONESIDED_MOVED'
            elif pp == gg and qq == gg:
                v = 'SAME_AGREE'
            elif pp != gg and qq == gg:
                v = 'TOGOLD'
            elif pp == gg and qq != gg:
                v = 'AWAY'
            elif pp == qq:
                v = 'STILLWRONG'
            else:
                v = 'MOVEDWRONG'
            c[v] = c.get(v, 0) + 1
            tot[v] = tot.get(v, 0) + 1
            if v in ('AWAY', 'MOVEDWRONG', 'NOGOLD', 'ONESIDED_MOVED'):
                bad.append((v, arm, k, gg, pp, qq))
        print('%-46s %s' % (os.path.basename(arm.rstrip('/')),
                            '  '.join('%s=%d' % (a, b)
                                      for a, b in sorted(c.items()))))
    print('-- TOTAL  ' + '  '.join('%s=%d' % (a, b)
                                   for a, b in sorted(tot.items())))
    for v, arm, k, gg, pp, qq in bad:
        print('   [%s] %s %s' % (v, os.path.basename(arm.rstrip('/')), k))
        print('       G:%s' % (sorted(gg) if gg else gg))
        print('       P:%s' % (sorted(pp) if pp else pp))
        print('       Q:%s' % (sorted(qq) if qq else qq))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
