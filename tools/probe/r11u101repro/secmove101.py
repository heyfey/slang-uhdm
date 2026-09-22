#!/usr/bin/env python3
"""r11u101 per-ENTRY whole-dump mover scorer: for each arm, the display-free
distance of every top-level entry (def view / top / package) on tag A and on
tag B, via slot101.sections().  AWAY = an entry whose distance to golden
GROWS; CLOSER = shrinks.  usage: secmove101.py <tagA> <tagB> <arm-dir>..."""
import difflib
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import slot101  # noqa: E402


def per(g, o):
    x, y = slot101.sections(g), slot101.sections(o)
    return {k: sum(1 for l in difflib.ndiff(x.get(k, []), y.get(k, []))
                   if l[:1] in '+-') for k in set(x) | set(y)}


ta, tb = sys.argv[1], sys.argv[2]
away = closer = arms = 0
sa = sb = 0
for d in sys.argv[3:]:
    a = os.path.basename(d.rstrip('/'))
    f = [os.path.join(d, '%s.%s.dump' % (s, t)) for t in (ta, tb)
         for s in ('gold', 'ours')]
    if not all(os.path.exists(x) for x in f):
        continue
    arms += 1
    pa, pb = per(f[0], f[1]), per(f[2], f[3])
    sa += sum(pa.values())
    sb += sum(pb.values())
    for k in sorted(set(pa) | set(pb), key=str):
        va, vb = pa.get(k, 0), pb.get(k, 0)
        if vb > va:
            away += 1
            print('  AWAY %s %d->%d %s %s' % (a, va, vb, k[0], k[1]))
        elif vb < va:
            closer += 1
            print('  CLOSER %s %d->%d %s %s' % (a, va, vb, k[0], k[1]))
print('ENTRY AWAY=%d CLOSER=%d distsec %d -> %d (arms=%d, %s -> %s)'
      % (away, closer, sa, sb, arms, ta, tb))
