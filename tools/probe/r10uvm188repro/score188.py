#!/usr/bin/env python3
# r10uvm188 — SCORE A CENSUS TRIPLE OF ENUM-CONSTANT ROWS.
# MEASUREMENT ONLY; the official uhdm-cmp is the acceptance judge.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: score188.py <golden.cen> <pristine.cen> <patched.cen> [--only-moved]
#
# Rows are ct188cen lines, '|'-separated:
#   TAG | file | parentKind | parentName | constName | span |
#   DEC=.. | SZ=.. | VAL=.. | N=n
# The KEY is TAG + parentKind + parentName + constName + span; the VALUE is
# DEC/SZ/VAL.  The FILE column is deliberately OUT of the key: our enum_consts
# carry an EMPTY VpiFile (the same residue our hier_paths have) while golden's
# name the source, so keying on it joins NOTHING and turns all 43k cells into
# one-sided keys.  VpiFile is not a field any generated Compare reads.  A key can carry
# MORE THAN ONE value (the DEF and the ELABORATED listing of one constant share
# every key field), so the join is a MULTISET expanded by N — a last-writer dict
# would silently drop the second listing and manufacture a one-sided set.
#
# The parent enum_typespec's SPAN is deliberately NOT in the key: golden anchors
# a package enum typespec at the typedef's USE site and we anchor it at the
# declaration, a difference the judge does not read on this object and which
# would split every key in two.
#
# Verdicts per key, over (golden, pristine, patched):
#   MATCH-KEPT           pris == gold and patched == gold
#   TO-GOLDEN            pris != gold and patched == gold        <- the law working
#   AWAY-GOLDEN          pris == gold and patched != gold        <- MUST BE 0
#   CHANGED-STILL-WRONG  pris != patched, neither == gold        <- MUST BE 0
#   WRONG-KEPT           pris == patched != gold                 (untouched residue)
#   ONE-SIDED-KEY        the key is absent on one of the three sides
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
            val = '|'.join(parts[6:9])
            m[key].extend([val] * n)
    for k in m:
        m[k].sort()
    return m


def main():
    if len(sys.argv) < 4:
        print('usage: score188.py <golden.cen> <pristine.cen> <patched.cen> '
              '[--only-moved]')
        return 2
    only_moved = '--only-moved' in sys.argv
    g, o, q = (load(x) for x in sys.argv[1:4])
    keys = sorted(set(g) | set(o) | set(q))
    tally = collections.Counter()
    lines = []
    for k in keys:
        gv, ov, qv = g.get(k), o.get(k), q.get(k)
        if gv is None or ov is None or qv is None:
            # A key only golden has is the ordinary state of a corpus row we
            # decline to emit at all; it is reported, never scored as a move.
            tally['ONE-SIDED-KEY'] += 1
            if ov != qv:
                lines.append('ONE-SIDED-KEY-MOVED\t%s\n    gold %s\n    pris %s'
                             '\n    patched %s' % (k, gv, ov, qv))
            continue
        if ov == gv and qv == gv:
            tally['MATCH-KEPT'] += 1
            continue
        if ov != gv and qv == gv:
            tally['TO-GOLDEN'] += 1
            lines.append('TO-GOLDEN\t%s\n    gold %s\n    pris %s' % (k, gv, ov))
            continue
        if ov == gv and qv != gv:
            tally['AWAY-GOLDEN'] += 1
            lines.append('AWAY-GOLDEN\t%s\n    gold %s\n    patched %s' %
                         (k, gv, qv))
            continue
        if ov != qv:
            tally['CHANGED-STILL-WRONG'] += 1
            lines.append('CHANGED-STILL-WRONG\t%s\n    gold %s\n    pris %s\n'
                         '    patched %s' % (k, gv, ov, qv))
            continue
        tally['WRONG-KEPT'] += 1
        if not only_moved:
            lines.append('WRONG-KEPT\t%s\n    gold %s\n    ours %s' % (k, gv, ov))
    for l in lines:
        print(l)
    print('-- CELLS=%d  ' % len(keys) + '  '.join(
        '%s=%d' % (k, tally[k]) for k in
        ('MATCH-KEPT', 'TO-GOLDEN', 'AWAY-GOLDEN', 'CHANGED-STILL-WRONG',
         'WRONG-KEPT', 'ONE-SIDED-KEY')))
    bad = tally['AWAY-GOLDEN'] + tally['CHANGED-STILL-WRONG']
    print('VERDICT: %s' % ('PASS' if bad == 0 else 'FAIL'))
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
