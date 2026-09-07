#!/usr/bin/env python3
# r10earl114 -- read the PX grid family out of a cen114 census and print the
# GOLDEN / PRISTINE / PATCHED first-operand size for every cell of the matrix.
#
# MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
# LHS is ALWAYS golden; RHS is ALWAYS ours.
#
# PX's key is span + scope + generate depth + carrier + the clone gate, none of
# which this law touches, so a cell that moves moves in its PAYLOAD alone.  The
# payload is operand 0's kind and the compare-visible expr fields on it.
#
#   usage: px113.py <armdir> [<armdir> ...]
# each <armdir> is a grid113.sh output dir holding cen.gold.txt / cen.pris.txt /
# cen.patch.txt.  A missing file is REPORTED, never skipped silently.
import os
import sys


def load(path):
    if not os.path.exists(path):
        return None
    out = {}
    for line in open(path):
        if '|PX|' not in line:
            continue
        parts = line.rstrip('\n').split('\t')
        if len(parts) < 3:
            continue
        key, pay, cnt = parts[0], parts[1], parts[2]
        out.setdefault(key, {})[pay] = int(cnt)
    return out


def fmt(d, key):
    if d is None:
        return 'NOFILE'
    v = d.get(key)
    if v is None:
        return '-'
    return ' + '.join(sorted('%s x%d' % (p, c) for p, c in v.items()))


def main(argv):
    rc = 0
    for arm in argv:
        g = load(os.path.join(arm, 'cen.gold.txt'))
        p = load(os.path.join(arm, 'cen.pris.txt'))
        q = load(os.path.join(arm, 'cen.patch.txt'))
        print('== %s' % arm)
        if g is None or p is None or q is None:
            print('   MISSING CENSUS FILE(S) -- gold=%s pris=%s patch=%s' %
                  (g is not None, p is not None, q is not None))
            rc = 1
            continue
        keys = sorted(set(g) | set(p) | set(q))
        for k in keys:
            gg, pp, qq = fmt(g, k), fmt(p, k), fmt(q, k)
            flag = '   ' if gg == pp == qq else ('MOV' if pp != qq else 'DIF')
            print('  %s %s' % (flag, k))
            print('        G: %s' % gg)
            print('        P: %s' % pp)
            print('        Q: %s' % qq)
    return rc


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
