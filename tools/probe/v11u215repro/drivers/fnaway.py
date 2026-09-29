#!/usr/bin/env python3
"""v11u215: raw full-name multiset census of one triple of uhdm-dumps: away = (pris & golden) - law, toward = (law & golden) - pris.
usage: fnaway.py <g.dump> <pris.dump> <law.dump> [v]"""
import sys, re, collections
def fn(p):
    c = collections.Counter()
    for l in open(p, errors='replace'):
        for m in re.finditer(r'vpiFullName:(\S+)', l): c[m.group(1)] += 1
    return c
G, P, L = (fn(p) for p in sys.argv[1:4])
away = (P & G) - L; tow = (L & G) - P; gone = P - L; new = L - P
print(f'fn away={sum(away.values())} toward={sum(tow.values())} changed_lines={sum(gone.values())}->{sum(new.values())} new_not_in_golden={sum((new - G).values())}')
if len(sys.argv) > 4:
    for k, v in away.items(): print('  AWAY', v, k)
    for k, v in (new - G).items(): print('  NEWBAD', v, k)
