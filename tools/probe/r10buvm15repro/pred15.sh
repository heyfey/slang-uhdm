#!/usr/bin/env bash
# r10buvm15repro/pred15.sh — THE MOVER PREDICTOR, read off PRISTINE BYTES ONLY,
# before the patched binary is allowed to speak.
#
#   usage: pred15.sh <pristine workdir root> <out-prefix>   > predictions
#
# THE PRISTINE SIGNATURE of § retNameRecvCollapseArgsBindLikeBody15 is exact,
# not an upper bound: the law changes ONE field — an argument ref_obj's
# `Actual_group` — under a call whose callee is the ENCLOSING function.  Any
# database that will move must therefore already show a `coll=1` census row
# whose argument list DISAGREES with golden, and no other.  This script runs the
# census over the pristine workdir on both sides and prints exactly those rows,
# reduced to the DATABASE NAMES that must move.
#
# GUARDS:
#   * the census is run on BOTH sides out of the SAME workdir, so a prediction
#     can never be made against a golden the sweep did not use.
#   * ARITY / golden-only / ours-only keys are printed SEPARATELY and are NOT
#     predicted movers — they are shape residues this law does not touch, and
#     folding them in would let a prediction "cover" a mover it did not foresee.
set -u
WD=${1:?pristine workdir root}
P=${2:-/tmp/r10buvm15_pred}
D=$(cd "$(dirname "$0")" && pwd)
bash "$D/cenall15.sh" "$WD" "$P" | tail -1
echo "---- COLLAPSED-CALL rows that DISAGREE (these databases, and only these, must move)"
python3 "$D/cenjoin15.py" "$P.golden" "$P.ours" --only-collapsed |
  tee "$P.join" | grep -A2 '^DISAGREE'
echo "---- PREDICTED MOVER DATABASES"
grep '^DISAGREE' "$P.join" | awk '{print $2}' | awk -F'|' '{print $1}' | sort -u
echo "---- NOT predicted (shape residues this law does not touch)"
grep -cE '^(ARITY)' "$P.join" | sed 's/^/ARITY keys: /'
tail -1 "$P.join"
