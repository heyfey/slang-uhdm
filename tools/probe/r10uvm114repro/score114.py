#!/usr/bin/env python3
"""r10uvm114 — arm scorer.  MEASUREMENT ONLY.

Reads three tscen114 censuses (golden, pristine, patched) and reports the
multiset distance to golden before and after, plus the rows that MOVED.
Keys drop every serializer id and both traversal/parent chains (sharing is
invisible to uhdm-cmp); the payload is the Compare-visible bound shape.

  usage: score114.py <g.rg> <o.rg> <q.rg>
"""
import re
import sys
from collections import Counter


def norm(line):
    line = re.sub(r" (OID|RID|BID)=\d+", "", line)
    line = re.sub(r" PATH=.*", "", line)
    line = re.sub(r" CH=.*", "", line)
    # a listing object's QUALIFIED name and its bare clone's are the same decl
    line = re.sub(r"(TS \w+) [A-Za-z_0-9]+::", r"\1 ", line)
    return line.strip()


def load(p):
    with open(p) as f:
        return Counter(norm(l) for l in f if l.startswith("TS "))


g, o, q = (load(p) for p in sys.argv[1:4])


def dist(a, b):
    keys = set(a) | set(b)
    return sum(abs(a[k] - b[k]) for k in keys)


dpris, dpat = dist(g, o), dist(g, q)
print(f"DIST golden-vs-pristine={dpris}  golden-vs-patched={dpat}")
moved_to, moved_away, still = 0, 0, 0
for k in set(o) | set(q):
    if o[k] == q[k]:
        continue
    before, after = abs(g[k] - o[k]), abs(g[k] - q[k])
    tag = "TO-GOLDEN" if after < before else (
        "AWAY-GOLDEN" if after > before else "NEUTRAL")
    if tag == "TO-GOLDEN":
        moved_to += 1
    elif tag == "AWAY-GOLDEN":
        moved_away += 1
    else:
        still += 1
    print(f"MOVED {tag} g={g[k]} pris={o[k]} pat={q[k]} :: {k}")
print(f"CELLS moved-to-golden={moved_to} moved-away={moved_away} neutral={still}")
