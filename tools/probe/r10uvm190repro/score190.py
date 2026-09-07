#!/usr/bin/env python3
"""r10uvm190repro/score190.py — the golden x pristine x patched MULTISET join.

MEASUREMENT ONLY; the official ``uhdm-cmp`` is the judge.  LHS is ALWAYS golden
(Surelog); RHS is ALWAYS ours.

Reads three ``ct190cen`` outputs and reports, per SECTION (``PA`` = every
param_assign's Rhs presence, ``TDC`` = every typedef-alias clone's packed-range
bounds, ``TDCE`` = the enum-base clones only), how many cells

  TO-GOLDEN            wrong on pristine, right on patched
  AWAY-GOLDEN          right on pristine, wrong on patched      (must be 0)
  CHANGED-STILL-WRONG  moved but still not golden's             (must be 0)
  WRONG-KEPT           wrong on both, untouched
  RIGHT-KEPT           right on both

The join is a MULTISET join on (key -> payload counts): one typedef gives many
identical clone rows (BuildUVMPkg's ``uvm_field_flag_t`` gives thirty), and a
last-writer dict would silently drop all but one of them.  The per-key verdict
is computed from multiset INTERSECTION SIZES, so a key whose rows only permute
scores zero movement.

  usage: score190.py <golden.cen> <pristine.cen> <patched.cen>
                     [--section PA|TDC|TDCE] [--only-moved]
"""
import sys
from collections import Counter, defaultdict


def load(path, section):
    """key -> Counter(payload).  The key is every column but the last; the
    payload is the last column.  A row whose section does not match is
    dropped."""
    d = defaultdict(Counter)
    n = 0
    with open(path, encoding='utf-8', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n')
            if not line:
                continue
            cols = line.split('\t')
            if len(cols) < 3:
                continue
            if section and cols[1] != section:
                continue
            d[tuple(cols[:-1])][cols[-1]] += 1
            n += 1
    return d, n


def inter(a, b):
    """Multiset intersection size."""
    return sum(min(v, b[k]) for k, v in a.items())


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    flags = [a for a in sys.argv[1:] if a.startswith('--')]
    if len(args) < 3:
        print(__doc__)
        return 2
    section = ''
    for f in flags:
        if f.startswith('--section='):
            section = f.split('=', 1)[1]
    if '--section' in flags:
        section = sys.argv[sys.argv.index('--section') + 1]
    only_moved = '--only-moved' in flags

    G, ng = load(args[0], section)
    A, na = load(args[1], section)
    B, nb = load(args[2], section)
    print('section=%s  golden rows=%d  pristine rows=%d  patched rows=%d' %
          (section or 'ALL', ng, na, nb))

    keys = set(G) | set(A) | set(B)
    tot = Counter()
    moved = []
    for k in sorted(keys):
        g, a, b = G.get(k, Counter()), A.get(k, Counter()), B.get(k, Counter())
        ma, mb = inter(g, a), inter(g, b)
        na_, nb_ = sum(a.values()), sum(b.values())
        tot['golden'] += sum(g.values())
        tot['ours-pris'] += na_
        tot['ours-pat'] += nb_
        tot['match-pris'] += ma
        tot['match-pat'] += mb
        if a != b:
            # cells that changed at all
            ch = sum((a - b).values()) + sum((b - a).values())
            tot['changed'] += ch
            to = max(0, mb - ma)
            aw = max(0, ma - mb)
            tot['TO-GOLDEN'] += to
            tot['AWAY-GOLDEN'] += aw
            # a changed cell that neither gained nor lost agreement
            tot['CHANGED-STILL-WRONG'] += max(0, min(ch, ch) - to - aw) \
                if (to == 0 and aw == 0) else 0
            moved.append((k, g, a, b, ma, mb))
        else:
            tot['WRONG-KEPT'] += na_ - ma
            tot['RIGHT-KEPT'] += ma

    print('  golden cells      %d' % tot['golden'])
    print('  our cells         pristine %d   patched %d' %
          (tot['ours-pris'], tot['ours-pat']))
    print('  matching golden   pristine %d   patched %d' %
          (tot['match-pris'], tot['match-pat']))
    print('  changed cells     %d' % tot['changed'])
    print('  TO-GOLDEN           %d' % tot['TO-GOLDEN'])
    print('  AWAY-GOLDEN         %d' % tot['AWAY-GOLDEN'])
    print('  CHANGED-STILL-WRONG %d' % tot['CHANGED-STILL-WRONG'])
    print('  WRONG-KEPT          %d' % tot['WRONG-KEPT'])
    print('  RIGHT-KEPT          %d' % tot['RIGHT-KEPT'])
    print('  moved keys          %d' % len(moved))
    if only_moved or len(moved) <= 40:
        for k, g, a, b, ma, mb in moved:
            print('  KEY %s' % ' | '.join(k))
            for lbl, c in (('golden  ', g), ('pristine', a), ('patched ', b)):
                for p, n in sorted(c.items()):
                    print('     %s x%-4d %s' % (lbl, n, p))
            print('     match pristine=%d patched=%d' % (ma, mb))
    return 0


if __name__ == '__main__':
    sys.exit(main())
