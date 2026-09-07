#!/usr/bin/env python3
# r10uvm187 — SCORE A CENSUS TRIPLE.  MEASUREMENT ONLY; the official uhdm-cmp
# is the acceptance judge.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: score187.py <golden.cen> <pristine.cen> <patched.cen>
#
# Rows are ct187cen lines:  VIEW \t OWNER \t PARAM \t LOC \t KIND \t VALUE.
# The KEY is the first five fields; the VALUE is the sixth.  Keys are joined as
# a MULTISET (a plain dict would drop a colliding row and manufacture a
# one-sided set out of nothing), and BOTH one-sided sets are printed.
#
# Verdicts per key, over (golden, pristine, patched):
#   MATCH-KEPT       pris == gold and patched == gold
#   TO-GOLDEN        pris != gold and patched == gold          <- the law working
#   AWAY-GOLDEN      pris == gold and patched != gold          <- MUST BE 0
#   CHANGED-STILL-WRONG  pris != patched, neither == gold      <- MUST BE 0
#   WRONG-KEPT       pris == patched != gold                   (untouched residue)
import collections
import sys


def load(p):
    m = collections.defaultdict(list)
    with open(p) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line:
                continue
            parts = line.split('\t')
            if len(parts) < 6:
                continue
            m['|'.join(parts[:5])].append(parts[5])
    for k in m:
        m[k].sort()
    return m


def main():
    if len(sys.argv) < 4:
        print('usage: score187.py <golden.cen> <pristine.cen> <patched.cen>')
        return 2
    g, o, q = (load(x) for x in sys.argv[1:4])
    keys = sorted(set(g) | set(o) | set(q))
    tally = collections.Counter()
    lines = []
    for k in keys:
        gv, ov, qv = g.get(k), o.get(k), q.get(k)
        if gv is None or ov is None or qv is None:
            tally['ONE-SIDED-KEY'] += 1
            lines.append('ONE-SIDED-KEY\t%s\tgold=%s\tpris=%s\tpatched=%s' %
                         (k, gv, ov, qv))
            continue
        if ov == gv and qv == gv:
            tally['MATCH-KEPT'] += 1
            continue
        if ov != gv and qv == gv:
            tally['TO-GOLDEN'] += 1
            lines.append('TO-GOLDEN\t%s\n    gold %s\n    pris %s' %
                         (k, gv[0], ov[0]))
            continue
        if ov == gv and qv != gv:
            tally['AWAY-GOLDEN'] += 1
            lines.append('AWAY-GOLDEN\t%s\n    gold %s\n    patched %s' %
                         (k, gv[0], qv[0]))
            continue
        if ov != qv:
            tally['CHANGED-STILL-WRONG'] += 1
            lines.append('CHANGED-STILL-WRONG\t%s\n    gold %s\n    pris %s\n'
                         '    patched %s' % (k, gv[0], ov[0], qv[0]))
            continue
        tally['WRONG-KEPT'] += 1
        lines.append('WRONG-KEPT\t%s\n    gold %s\n    ours %s' %
                     (k, gv[0], ov[0]))
    for l in lines:
        print(l)
    print('-- CELLS=%d  ' % len(keys) + '  '.join(
        '%s=%d' % (k, tally[k]) for k in
        ('MATCH-KEPT', 'TO-GOLDEN', 'AWAY-GOLDEN', 'CHANGED-STILL-WRONG',
         'WRONG-KEPT', 'ONE-SIDED-KEY')))
    bad = tally['AWAY-GOLDEN'] + tally['CHANGED-STILL-WRONG'] + \
        tally['ONE-SIDED-KEY']
    print('VERDICT: %s' % ('PASS' if bad == 0 else 'FAIL'))
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
