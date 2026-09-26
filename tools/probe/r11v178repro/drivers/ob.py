#!/usr/bin/env python3
# ob.py <casedir-in-grid> : order-blind distance of pris and law records to golden; prints records ours-not-in-golden per side
import sys, collections
d = sys.argv[1]
def C(f): return collections.Counter('\t'.join(l.rstrip('\n').split('\t')[1:14]) for l in open(f, errors='replace'))
g = C(d + '/pris.a.txt'); g2 = C(d + '/law.a.txt'); assert g == g2
p = C(d + '/pris.b.txt'); l = C(d + '/law.b.txt')
dp = sum((p - g).values()) + sum((g - p).values()); dl = sum((l - g).values()) + sum((g - l).values())
print(d, 'pris', dp, 'law', dl, 'TOWARD' if dl < dp else 'AWAY' if dl > dp else 'SAME')
if len(sys.argv) > 2:
    print('--- law-only records not in golden (new wrong):'); [print('  ', k, v) for k, v in (l - g - (p - g)).items()]
    print('--- pris-only records not in golden (fixed):'); [print('  ', k, v) for k, v in (p - g - (l - g)).items()]
