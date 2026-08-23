#!/usr/bin/env python3
"""Three-way multiset score: golden vs pristine vs patched cell censuses."""
import sys
from collections import Counter

g = Counter(open(sys.argv[1]).read().splitlines())
p = Counter(open(sys.argv[2]).read().splitlines())
q = Counter(open(sys.argv[3]).read().splitlines())
tag = sys.argv[4]

def inter(a, b):
    c = Counter()
    for k in a:
        n = min(a[k], b[k])
        if n: c[k] = n
    return c

ip, iq = inter(g, p), inter(g, q)
lost = ip - iq          # golden-agreeing cells the patch destroyed
gain = iq - ip          # golden-agreeing cells the patch created
# cells the patch mints that golden does not have at all
mint = (q - g) - (p - g)
print('%s AGREE_pris=%d AGREE_pat=%d GOLDEN=%d PRIS=%d PAT=%d LOST=%d GAIN=%d NEWMINT=%d'
      % (tag, sum(ip.values()), sum(iq.values()), sum(g.values()),
         sum(p.values()), sum(q.values()), sum(lost.values()),
         sum(gain.values()), sum(mint.values())))
for k, n in sorted(lost.items()):
    print('  REGRESS[%d] %s' % (n, k))
for k, n in sorted(gain.items()):
    print('  IMPROVE[%d] %s' % (n, k))
for k, n in sorted(mint.items()):
    print('  NEWMINT[%d] %s' % (n, k))
