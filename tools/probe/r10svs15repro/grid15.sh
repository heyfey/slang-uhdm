#!/usr/bin/env bash
# r10svs15 THE GRID, CELL FOR CELL, BOTH BINARIES IN ONE TABLE.
#
#   usage: ./grid15.sh <arm-tag>        # reads /tmp/r10svs15_arm_{pris,ship}_<tag>
#          ./grid15.sh svs              # reads /tmp/r10svs15_svs_{pris,ship}
#                                       #   (the witness pair, `default` mode)
#
# A CELL is one clocking-block EVENT-EXPRESSION `ref_obj`, keyed by (vpiFullName,
# source span) exactly as cbcensus.sh keys it; the value is its `vpiActual`
# target.  All three columns are read from dumps ALREADY ON DISK, so the table is
# re-readable without re-running any tool.
#
# The verdict column is the pair (PRIS vs GOLDEN, SHIP vs GOLDEN):
#   EQ->EQ     held          DIF->EQ    CONVERGED
#   EQ->DIF    REGRESSED     DIF->DIF   stillDIF (content printed when it moved)
# A cell absent from a column is `-` and verdicts involving it are `MISSING`,
# never silently dropped -- a grid that drops a row reads exactly like a grid
# where the row agrees.
#
# THE GOLDEN COLUMN MUST BE IDENTICAL IN BOTH RUNS.  Each binary gets its own arm
# scratch directory so both columns survive on disk, and that directory is part of
# every `file:` field, so the two golden dumps differ by THAT PATH and nothing
# else; the assertion is made on the PATH-NORMALISED text and a real difference
# refuses the table (exit 4) instead of printing a meaningless one.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:?arm tag, e.g. a1, or `svs` for the witness}
if [ "$TAG" = svs ]; then
    P=/tmp/r10svs15_svs_pris; S=/tmp/r10svs15_svs_ship
    GP=$P/default.g.dump; GS=$S/default.g.dump
    OP=$P/default.o.dump; OS=$S/default.o.dump
else
    P=/tmp/r10svs15_arm_pris_$TAG; S=/tmp/r10svs15_arm_ship_$TAG
    GP=$P/g.dump; GS=$S/g.dump; OP=$P/o.dump; OS=$S/o.dump
fi
for f in "$GP" "$GS" "$OP" "$OS"; do
    [ -s "$f" ] || { echo "MISSING DUMP: $f"; exit 6; }
done
if ! diff -q <(sed "s#$P#WD#g" "$GP") <(sed "s#$S#WD#g" "$GS") >/dev/null; then
    echo "GOLDEN DUMPS DIFFER BETWEEN THE TWO RUNS (beyond the scratch path)"
    echo "  -- table refused; the two columns are not against the same golden"
    diff <(sed "s#$P#WD#g" "$GP") <(sed "s#$S#WD#g" "$GS") | head -10
    exit 4
fi
python3 - "$HERE" "$GP" "$OP" "$OS" <<'PY'
import re, subprocess, sys
here, gp, op, os_ = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]


def read(a, b):
    """cbcensus.sh's own table, re-read by FIXED COLUMN (its format string is
    `%-46s %-26s %-34s %-34s %s`).  Parsing its output rather than duplicating
    its parser keeps ONE definition of what a cell is."""
    out = subprocess.run(['bash', here + '/cbcensus.sh', a, b],
                         capture_output=True, text=True).stdout
    cells = {}
    for ln in out.split('\n')[1:]:
        if not ln.strip() or ln.startswith('CELLS'):
            continue
        name = ln[0:46].strip()
        span = ln[47:73].strip()
        lhs = ln[74:108].strip()
        rhs = ln[109:143].strip()
        cells[(name, span)] = (lhs, rhs)
    return cells


# LHS is ALWAYS golden, so column 1 of either read is the golden column; they
# must agree, and the assertion above already proved the dumps do.
P = read(gp, op)
S = read(gp, os_)
# THE GRID IS THE CLOCKING-EVENT-REF GRID, and it says so with a filter rather
# than by convention: a cell is kept when the ref's fullname passes through a
# clocking BLOCK (`<view>.<cb-name>.<signal>` -- `cb`, `cba`, `cbb` on the arms).
# The UNFILTERED instrument is cbcensus.sh, which reports every ref_obj in the
# database and is what §'s residue list is read from; narrowing HERE and saying
# so is the honest way to keep the verdict counts about this pass's carrier.
keys = sorted(k for k in set(P) | set(S) if re.search(r'\.cb\w*\.', k[0]))
n = {}
print('%-40s %-30s %-30s %-30s %-9s %s'
      % ('REF FULLNAME', 'GOLDEN', 'PRIS', 'SHIP', 'PRIS->SHIP', 'verdict'))
for k in keys:
    p, s = P.get(k), S.get(k)
    g = (p or s)[0]
    pv = p[1] if p else '-'
    sv = s[1] if s else '-'
    if p is None or s is None or g == '-':
        verd, pair = 'MISSING', '?'
    else:
        a = 'EQ' if p[0] == p[1] else 'DIF'
        b = 'EQ' if s[0] == s[1] else 'DIF'
        pair = a + '->' + b
        verd = {'EQ->EQ': 'held', 'DIF->EQ': 'CONVERGED',
                'EQ->DIF': 'REGRESSED', 'DIF->DIF': 'stillDIF'}[pair]
        if verd == 'stillDIF' and pv != sv:
            verd = 'stillDIF (content CHANGED)'
    n[verd.split(' ')[0]] = n.get(verd.split(' ')[0], 0) + 1
    print('%-40s %-30s %-30s %-30s %-9s %s'
          % (k[0][:40], g[:30], pv[:30], sv[:30], pair, verd))
print('CELLS %d   held %d   CONVERGED %d   REGRESSED %d   stillDIF %d   MISSING %d'
      % (len(keys), n.get('held', 0), n.get('CONVERGED', 0),
         n.get('REGRESSED', 0), n.get('stillDIF', 0), n.get('MISSING', 0)))
PY
