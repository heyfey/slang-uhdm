#!/usr/bin/env python3
# obaway.py <scratch case dir> [tagOn tagOff]: the order-blind uhdm-dump lines the ON database gets wrong
# (vs golden) that OFF did not (AWAY), and those OFF got wrong that ON fixed (TOWARD).
import sys, collections, os
STRIP = os.environ.get('STRIP') == '1'  # depth-blind
d = sys.argv[1]; a = sys.argv[2] if len(sys.argv) > 2 else 'on'; b = sys.argv[3] if len(sys.argv) > 3 else 'off'
def m(f): return collections.Counter((l.strip() if STRIP else l) for l in open(f, errors='replace').read().split('\n') if 'Restored design' not in l)
g, o, f = m(d + '/gold/ob.txt'), m(d + f'/{a}.ob.txt'), m(d + f'/{b}.ob.txt')
for nm, c in (('AWAY +', (o - g) - (f - g)), ('AWAY -', (g - o) - (g - f)), ('TOWARD (off extra fixed)', (f - g) - (o - g)), ('TOWARD (off missing fixed)', (g - f) - (g - o))):
    for l, k in c.items(): print(nm, k, l)
