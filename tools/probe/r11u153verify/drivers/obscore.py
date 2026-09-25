#!/usr/bin/env python3
# obscore.py <scratch root> <tagA> <tagB> <case>... : depth-blind order-blind uhdm-dump score of tagB against
# tagA (each vs golden): lines stripped of indentation, multisets; AWAY = golden-mismatching lines B has that A
# did not (extra or missing), TOWARD = the reverse. Prints per case: away toward.
import sys, collections
root, a, b = sys.argv[1:4]
def m(f):
    try: return collections.Counter(l.strip() for l in open(f, errors='replace').read().split('\n') if 'Restored design' not in l)
    except Exception: return None
for c in sys.argv[4:]:
    g, x, y = m(f'{root}/{c}/gold/ob.txt'), m(f'{root}/{c}/{a}.ob.txt'), m(f'{root}/{c}/{b}.ob.txt')
    if g is None or x is None or y is None: print(c, 'noob'); continue
    away = ((y - g) - (x - g)) + ((g - y) - (g - x)); tow = ((x - g) - (y - g)) + ((g - x) - (g - y))
    print(f'{c}\taway={sum(away.values())}\ttoward={sum(tow.values())}')
    if len(sys.argv) > 4 and sum(away.values()) and '-v' in sys.argv[0:1] + [c]: pass
