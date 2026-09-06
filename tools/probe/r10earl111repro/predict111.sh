#!/bin/bash
# r10earl111 -- THE MOVER PREDICTION, from PRISTINE databases only.
#
# MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
# LHS is ALWAYS golden; RHS is ALWAYS ours.
#
#   usage: predict111.sh <censweep rows.tsv> [<rows.tsv> ...]
#
# The law can only ever touch a constant that is ALREADY in our database in the
# `IPS.width` slot, ALREADY BARE, and sized as a 32-bit integer -- because it
# folds nothing new, moves nothing, and mints exactly one ref_typespec onto an
# existing folded width whose parameter is declared `int`.  An `int` fold is
# VpiSize 32 with ct9 (vpiUIntConst) or ct1/ct2 (a signed/dec const).
#
# So the OVER-PREDICTION is: every (row, key) where OUR side has a BARE
# IPS.width constant of size 32.  It is printed in two buckets:
#   MOVE   golden has a typespec there -- the patch is predicted to convert it
#   RISK   golden is BARE there too    -- the law MUST refuse it; any of these
#          that the patch changes is an AWAY and the pass fails
# Anything outside the IPS.width slot, or of another size, cannot move at all.
set -u
python3 - "$@" <<'PY'
import sys
from collections import Counter, defaultdict

g = defaultdict(Counter)
o = defaultdict(Counter)
for p in sys.argv[1:]:
    for line in open(p):
        c = line.rstrip("\n").split("\t")
        if len(c) < 5:
            continue
        (g if c[0] == "G" else o)[(c[1], c[2])][c[3]] += int(c[4])

move, risk, scanned = [], [], 0
for k, pay in o.items():
    slot = k[1].split("|")[0]
    size = k[1].split("|")[3]
    if slot != "IPS.width" or size != "32":
        continue
    if "BARE" not in pay:
        continue
    scanned += 1
    gp = g.get(k)
    if gp and all(x != "BARE" for x in gp):
        move.append((k, dict(gp), dict(pay)))
    elif gp is None:
        risk.append((k, "NO-GOLDEN-KEY", dict(pay)))
    elif "BARE" in gp and len(gp) == 1:
        risk.append((k, dict(gp), dict(pay)))
    else:
        risk.append((k, dict(gp), dict(pay)))

print("SCANNED bare 32-bit IPS.width keys: %d" % scanned)
print("PREDICT MOVE %d   PREDICT RISK(must not move) %d" % (len(move), len(risk)))
print("\n--- MOVE (golden stamped, ours bare) ---")
for k, a, b in sorted(move):
    print("%s\n\t%s\n\tG %s\n\tO %s" % (k[0], k[1], a, b))
print("\n--- RISK (golden bare or unjoined; the law must leave these alone) ---")
for k, a, b in sorted(risk):
    print("%s\n\t%s\n\tG %s\n\tO %s" % (k[0], k[1], a, b))
rows = sorted({k[0] for k, _, _ in move})
print("\nROWS PREDICTED TO MOVE (%d):" % len(rows))
for r in rows:
    print("  " + r)
PY
