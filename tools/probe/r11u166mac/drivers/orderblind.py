#!/usr/bin/env python3
"""orderblind.py <golden.rec> <pristine.rec> <law.rec> — order-blind record census for a row whose walk diverges
from golden: multiset of full records (depth dropped).  GAINED = law records that match a golden record and replace
pristine records that did not (lost pristine-only records); LOST = pristine records matching golden that the law no
longer produces.  Prints gained/lost counts and up to 10 lost records."""
import sys
from collections import Counter
def load(p):
    c = Counter()
    for l in open(p):
        f = l.rstrip('\n').split('\t')
        c['\t'.join(f[1:])] += 1
    return c
G, P, L = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
pm = sum((P & G).values()); lm = sum((L & G).values())
moved_p = P - L; moved_l = L - P
lost = Counter({k: v for k, v in ((P & G) - (L & G)).items() if v > 0})
gained = Counter({k: v for k, v in ((L & G) - (P & G)).items() if v > 0})
print('golden=%d pristine_match=%d law_match=%d gained=%d lost=%d moved=%d' %
      (sum(G.values()), pm, lm, sum(gained.values()), sum(lost.values()), sum(moved_p.values())))
for k, v in list(lost.items())[:10]:
    print('LOST x%d %s' % (v, k))
