#!/usr/bin/env python3
"""r10earl98 -- REGRESSION SCORER over a FIXED key universe.

  usage: reg98.py <golden.cen> <pristine.cen> <patched.cen>

LHS is ALWAYS golden.  The golden census is the reference; the two candidate
censuses are scored against it over the SAME key universe, and the per-key
payload multisets are intersected three ways so every cell lands in exactly
one bucket:

  TO-GOLDEN    a key whose payload multiset was WRONG in pristine and is RIGHT
               in patched
  AWAY-GOLDEN  RIGHT in pristine, WRONG in patched      <- must be 0
  STILL-WRONG  wrong in both (and unchanged)
  CHANGED-WRONG wrong in both but DIFFERENTLY            <- must be 0
  BOTH-RIGHT   right in both
  ADDED / REMOVED   keys that exist in one candidate and not the other
Also asserts the two candidates cover the same key universe as each other.
"""
import sys, collections

def load(p):
    m = collections.defaultdict(collections.Counter)
    for line in open(p):
        line = line.rstrip("\n")
        if not line: continue
        c, rest = line.split("\t", 1)
        key, pay = rest.rsplit("\t", 1)
        m[key][pay] += int(c)
    return m

def main():
    g, a, b = (load(x) for x in sys.argv[1:4])
    detail = "--detail" in sys.argv[4:]
    to = away = still = chg = right = 0
    added = removed = 0
    det = []
    for k in set(a) | set(b):
        if k in a and k not in b:
            removed += 1; det.append("REMOVED %s" % k); continue
        if k in b and k not in a:
            added += 1; det.append("ADDED %s" % k); continue
        gp = g.get(k)
        ap, bp = a[k], b[k]
        ra = (gp is not None and ap == gp)
        rb = (gp is not None and bp == gp)
        if ra and rb: right += 1
        elif not ra and rb:
            to += 1
            if detail: det.append("TO-GOLDEN %s golden=%s pris=%s" % (k, dict(gp), dict(ap)))
        elif ra and not rb:
            away += 1
            det.append("AWAY-GOLDEN %s golden=%s patc=%s" % (k, dict(gp) if gp else None, dict(bp)))
        else:
            if ap == bp: still += 1
            else:
                chg += 1
                det.append("CHANGED-WRONG %s golden=%s pris=%s patc=%s" %
                           (k, dict(gp) if gp else None, dict(ap), dict(bp)))
    print("TO-GOLDEN %d AWAY-GOLDEN %d STILL-WRONG %d CHANGED-WRONG %d "
          "BOTH-RIGHT %d ADDED %d REMOVED %d" %
          (to, away, still, chg, right, added, removed))
    for d in sorted(det): print("  " + d)

main()
