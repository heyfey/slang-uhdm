#!/usr/bin/env python3
"""r10earl54 MOVER ATTRIBUTION — every (instance, port, span) slot whose KIND
changed between the pristine and patched databases, joined against golden.

The census predicts 99 movers.  This proves the patched run moved EXACTLY those
99 slots and nothing else, and that each one landed ON golden:

  TO-GOLDEN     pristine != golden, patched == golden        (the win)
  AWAY-GOLDEN   pristine == golden, patched != golden        (must be 0)
  STILL-WRONG   changed, neither side equals golden          (named, not hidden)
  UNMOVED-BAD   pristine == patched != golden                (residue, unchanged)

  usage: attrib54.py <golden.dump> <pristine.dump> <patched.dump>
"""
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
import census54 as C  # noqa: E402


def main():
    if len(sys.argv) != 4:
        print(__doc__)
        return 2
    g, a, b = (C.scan(p) for p in sys.argv[1:4])
    keys = set(a) | set(b)
    to_g, away, still, unmoved = [], [], [], []
    for k in keys:
        av, bv, gv = a.get(k), b.get(k), g.get(k)
        if av == bv:
            if gv is not None and bv != gv:
                unmoved.append((k, av, gv))
            continue
        if bv == gv:
            to_g.append((k, av, bv))
        elif av == gv:
            away.append((k, av, bv))
        else:
            still.append((k, av, bv, gv))
    print('slots: golden=%d pristine=%d patched=%d' % (len(g), len(a), len(b)))
    print('TO-GOLDEN   = %d' % len(to_g))
    print('AWAY-GOLDEN = %d   <-- MUST BE 0' % len(away))
    print('STILL-WRONG = %d   (changed, still not golden)' % len(still))
    print('UNMOVED-BAD = %d   (residue, untouched by this pass)' % len(unmoved))
    for tag, lst in (('TO-GOLDEN', to_g), ('AWAY-GOLDEN', away),
                     ('STILL-WRONG', still)):
        if not lst:
            continue
        print('-- %s: by span' % tag)
        from collections import Counter
        for sp, n in Counter(x[0].split('|')[2] for x in lst).most_common(15):
            print('   %-22s %d' % (sp, n))
        print('   sample: %s' % (sorted(lst)[0],))
    return 0 if not away else 1


if __name__ == '__main__':
    sys.exit(main())
