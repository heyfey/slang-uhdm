#!/usr/bin/env bash
# r10earl34 — THE SOURCE-DERIVED MOVER FENCE.
#
# Computed from the PRISTINE dumps and the SOURCE alone, and written down
# BEFORE the patched sweeps were read.  § hpMixedIdxPkgFold34 can only change
# bytes where ALL THREE hold:
#
#   A. a hier_path DISPLAY NAME carries a select index, and
#   B. that index text names an identifier, and
#   C. the identifier resolves to a parameter/localparam DECLARED IN A PACKAGE
#      (module parameters, module localparams and genvars are excluded by the
#      gate `collectPkgParamFolds` already applies).
#
# ...and additionally the path must be built by emitMixedHierPath, i.e. the
# select sits on the BASE of a MEMBER-ACCESS chain (`a[IDX].m.n`) — the
# range-select arm already had the fold.
#
# usage: ./pred34.sh <pristine-dump>        (dump already sed 1d)
set -u
D=${1:?pristine dump (sed 1d)}
[ -f "$D" ] || { echo "FATAL: no such dump $D"; exit 9; }

echo "== A+B: distinct hier_path names with an IDENTIFIER-bearing index =="
grep -oE '\\_hier_path: \([^)]*\)' "$D" | sed -E 's/.*\((.*)\)/\1/' | sort -u \
  | grep -E '\[[^]]*[A-Za-z_][^]]*\]' > /tmp/pred34_idbearing.txt
wc -l < /tmp/pred34_idbearing.txt

echo "== C: of those, the ones whose index names a PACKAGE parameter =="
echo "   (the two families this design carries, by name)"
grep -E 'region_cfgs\[MpRegions\]' /tmp/pred34_idbearing.txt || true
echo "-- genvar-indexed / module-param-indexed names that must NOT move: --"
grep -cE '\[(i|j|k|gi|genv)[^]]*\]' /tmp/pred34_idbearing.txt

echo
echo "PREDICTION: the only names that may move are the SIX"
echo "  region_cfgs[MpRegions].{base,size,en,rd_en,prog_en,erase_en}.q"
echo "each becoming region_cfgs[8].<...>.q, on Earlgrey_0_1/default only."
echo "Every other identifier-indexed name is genvar- or module-param-indexed"
echo "and is fenced OUT by collectPkgParamFolds' package-scope gate."
