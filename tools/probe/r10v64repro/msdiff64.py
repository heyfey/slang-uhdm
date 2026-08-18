#!/usr/bin/env python3
"""r10v64 — MULTISET distance of two dumps from golden, per distinct line.
usage: msdiff64.py g.s o.s p.s [topN]
Prints TOWARD/AWAY totals and the top AWAY lines (patched further from golden
than pristine was).  MEASUREMENT ONLY."""
import sys, collections
g = collections.Counter(open(sys.argv[1], errors='replace').read().splitlines())
o = collections.Counter(open(sys.argv[2], errors='replace').read().splitlines())
p = collections.Counter(open(sys.argv[3], errors='replace').read().splitlines())
top = int(sys.argv[4]) if len(sys.argv) > 4 else 25
keys = set(g) | set(o) | set(p)
do = dp = 0
away, toward = [], []
for k in keys:
    a = abs(g[k] - o[k]); b = abs(g[k] - p[k])
    do += a; dp += b
    if b > a: away.append((b - a, k, g[k], o[k], p[k]))
    elif a > b: toward.append((a - b, k, g[k], o[k], p[k]))
away.sort(reverse=True); toward.sort(reverse=True)
print("DIST_PRIS=%d DIST_PAT=%d  TOWARD=%d lines/%d cells  AWAY=%d lines/%d cells"
      % (do, dp, len(toward), sum(x[0] for x in toward),
         len(away), sum(x[0] for x in away)))
for d, k, gc, oc, pc in away[:top]:
    print("AWAY +%d g=%d o=%d p=%d | %s" % (d, gc, oc, pc, k[:150]))
