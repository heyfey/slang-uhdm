#!/usr/bin/env python3
"""r10v124 — MULTISET line audit.  For a (golden, pristine, patched) dump
triple: every line the patch REMOVED (count went down pris->pat) is checked
against golden's own multiset, and every line it ADDED is checked too.
A removal is BAD when golden holds at least as many of that line as pristine
did; an addition is BAD when the patched count EXCEEDS golden's count."""
import sys, re
from collections import Counter
def load(p):
    c = Counter()
    for l in open(p, errors='replace'):
        l = l.rstrip('\n').strip()
        if not l or 'Restored design' in l: continue
        l = re.sub(r', id:\d+', '', l)
        l = re.sub(r'file:[^,]*,', '', l)
        c[l] += 1
    return c
g, p, a = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
badrm = badadd = nrm = nadd = 0
for k in set(p) | set(a):
    d = a[k] - p[k]
    if d < 0:
        nrm += -d
        if g[k] >= p[k]: badrm += min(-d, g[k] - a[k])
    elif d > 0:
        nadd += d
        if a[k] > g[k]: badadd += a[k] - max(g[k], p[k])
print('%-30s removed=%d BAD_REMOVED=%d added=%d BAD_ADDED=%d' % (sys.argv[4], nrm, badrm, nadd, badadd))
if len(sys.argv) > 5:
    for k in sorted(set(p) | set(a)):
        d = a[k] - p[k]
        if d < 0 and g[k] >= p[k]:
            print('   BAD_RM  g=%d p=%d a=%d  %s' % (g[k], p[k], a[k], k))
        elif d > 0 and a[k] > g[k]:
            print('   BAD_ADD g=%d p=%d a=%d  %s' % (g[k], p[k], a[k], k))
