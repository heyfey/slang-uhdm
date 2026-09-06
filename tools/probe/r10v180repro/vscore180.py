#!/usr/bin/env python3
"""r10v180 — per-view three-way arm scorer.  Same verdicts as score180.py but
the DEF and ELAB dumps are scored SEPARATELY (score180.py keys on the path
alone over a file that cats the two views together, so a def row and an elab
row with the same path collide and the last writer wins)."""
import sys
from collections import OrderedDict

def load(p):
    d = OrderedDict()
    try:
        for line in open(p):
            q = line.rstrip("\n").split("\t")
            if len(q) >= 3:
                d[q[1]] = q[2]
    except FileNotFoundError:
        pass
    return d

G, A, B = (load(p) for p in sys.argv[1:4])
label = sys.argv[4] if len(sys.argv) > 4 else "arm"
tg = aw = mw = sw = ab = ga = gb = 0
for k in sorted(set(G) | set(A) | set(B)):
    g, a, b = G.get(k), A.get(k), B.get(k)
    if g is None:
        if a is not None or b is not None:
            print("NO-GOLDEN   %s  pris=%s pat=%s" % (k, a, b))
        continue
    if a is None or b is None:
        if a is None: ga += 1
        if b is None: gb += 1
        print("KEY-GAP     %s  gold=%s pris=%s pat=%s" % (k, g, a, b)); continue
    if a == g and b == g: ab += 1
    elif a != g and b == g: tg += 1; print("TOGOLD      %s  gold=%s was=%s" % (k, g, a))
    elif a == g and b != g: aw += 1; print("AWAY        %s  gold=%s now=%s" % (k, g, b))
    elif a != b: mw += 1; print("MOVED-WRONG %s  gold=%s was=%s now=%s" % (k, g, a, b))
    else: sw += 1; print("STILL-WRONG %s  gold=%s both=%s" % (k, g, a))
print("SCORE %s TOGOLD=%d AWAY=%d MOVED-WRONG=%d STILL-WRONG=%d AGREE-BOTH=%d KEYGAP-pris=%d KEYGAP-pat=%d cells=%d"
      % (label, tg, aw, mw, sw, ab, ga, gb, len(set(G)|set(A)|set(B))))
