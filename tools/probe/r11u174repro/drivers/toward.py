#!/usr/bin/env python3
"""toward.py <golden_records> <pristine_records> <law_records>: multiset comparison of strict record dumps
(uhdm-strictcmp --dump-a/--dump-b).  Prints how many record lines of each binary golden does NOT hold
(away), and how many golden lines each binary misses (missing); a law that moves only toward golden
lowers both or keeps them.  Record text includes depth, type, names, file, span, decompile, size, value."""
import sys
from collections import Counter
def load(p): return Counter(l for l in open(p).read().split('\n') if l)
A, P, L = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
awayP = sum((P - A).values()); awayL = sum((L - A).values())
missP = sum((A - P).values()); missL = sum((A - L).values())
print(f'away {awayP} -> {awayL}  missing {missP} -> {missL}  records {sum(P.values())} -> {sum(L.values())} (golden {sum(A.values())})')
if len(sys.argv) > 4:
    for l, n in sorted((L - A - (P - A)).items())[:int(sys.argv[4])]:
        print('  NEW-AWAY', n, l[:200])
