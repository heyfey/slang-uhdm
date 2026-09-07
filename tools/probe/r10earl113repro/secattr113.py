#!/usr/bin/env python3
"""r10earl113 -- the SECTIONED order-blind whole-dump attribution.

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.

  usage: secattr112.py <pris.dump> <patch.dump>

Both dumps must already be PATH-NORMALISED (attrib112.sh does that; a raw diff
of two workdirs is all noise because a dump embeds its workdir).

The dump is cut into three regions, and the cut is NOT `|uhdmtopModules:` alone
-- the LAST such section runs all the way to the end of the file and therefore
SWALLOWS the tail, which is how a tail-only change can be mistaken for an
elaborated one.  The regions are:

  DEF   everything before the first `|uhdmtopModules:`
  ELAB  from there to the `\\_weaklyReferenced:` marker
  TAIL  from `\\_weaklyReferenced:` on -- UNREACHABLE TO THE JUDGE, and by
        this campaign's rule (earl60's brief-refutation) NEVER COUNTED as a
        win or a loss.

Comparison is a MULTISET difference over (region, line), so a pure reordering
inside a region contributes nothing.
"""
import sys
from collections import Counter


def regions(p):
    out = []
    seen_top = False
    tail = False
    for line in open(p, errors="replace"):
        s = line.rstrip("\n")
        if "\\_weaklyReferenced:" in s:
            tail = True
        elif "|uhdmtopModules:" in s:
            seen_top = True
        r = "TAIL" if tail else ("ELAB" if seen_top else "DEF")
        out.append((r, s))
    return Counter(out)


a = regions(sys.argv[1])
b = regions(sys.argv[2])
add, rem = b - a, a - b
for name, d in (("ADDED", add), ("REMOVED", rem)):
    by = Counter()
    for (r, _), v in d.items():
        by[r] += v
    print("%s total %d   by region %s" % (name, sum(d.values()), dict(by)))
print("\n--- ADDED line shapes, DEF+ELAB only (the tail is not counted) ---")
sh = Counter()
for (r, l), v in add.items():
    if r == "TAIL":
        continue
    import re
    sh[re.sub(r"\d+", "N", l)] += v
for l, v in sh.most_common(30):
    print("%6d  %s" % (v, l))
print("\n--- REMOVED line shapes, DEF+ELAB only ---")
sh = Counter()
for (r, l), v in rem.items():
    if r == "TAIL":
        continue
    import re
    sh[re.sub(r"\d+", "N", l)] += v
for l, v in sh.most_common(30):
    print("%6d  %s" % (v, l))
