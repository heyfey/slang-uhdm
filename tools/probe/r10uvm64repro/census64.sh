#!/usr/bin/env bash
# r10uvm64 CORPUS CENSUS — the MOVER PREDICTION, made off the PRISTINE sweep's
# own databases, BEFORE gate 5's byte comparison is run.
#
#   usage: census64.sh <pristine_workdir_root> <outfile>
#
# WHAT IT COUNTS.  § blkLocalSameCtrlDepthWindowBinds64 can only ever ADD a
# `vpiActual` to a `ref_obj` that (1) today has NO vpiActual and (2) names a
# variable that some `begin` in the same database lists under `vpiVariables`.
# Those two facts are both readable off OUR OWN PRISTINE DUMP, so the candidate
# set is computable without the patched binary existing.
#
# IT IS DELIBERATELY A SUPERSET.  The dump does not print the control-body
# DEPTH, the class-vs-module scope of the enclosing subroutine, or whether the
# reference sits in an if/case CONDITION — the three terms of the real gate.  A
# database with zero candidates therefore CANNOT move; a database with
# candidates MAY move.  That asymmetry is the whole value: the prediction is a
# sound upper bound on the mover SET, which is what makes "the movers are
# exactly the predicted ones" a checkable claim instead of a sampled one.
#
# GUARDS:
#   * a database whose dump FAILS is counted as NO_DUMP and reported; it is
#     never silently treated as "0 candidates", which would read as safety.
#   * the arm control (b1_cond.sv) is re-run before the corpus scan in the
#     README, because a scanner that finds nothing on a file whose grid shows
#     six movers is measuring nothing at all.
set -u
WD=${1:?pristine workdir root}
OUT=${2:?outfile}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
: > "$OUT"
n=0; nodump=0; cand=0
while read -r db; do
  n=$((n + 1))
  rel=${db#"$WD"/}
  if ! "$DUMP" "$db" 2>/dev/null | sed 1d > /tmp/.r64census.$$; then
    echo "NO_DUMP $rel" >> "$OUT"; nodump=$((nodump + 1)); continue
  fi
  [ -s /tmp/.r64census.$$ ] || { echo "NO_DUMP $rel" >> "$OUT"; nodump=$((nodump + 1)); continue; }
  c=$(python3 "$(dirname "$0")/census64.py" /tmp/.r64census.$$)
  echo "$c $rel" >> "$OUT"
  [ "$c" = 0 ] || cand=$((cand + 1))
done < <(find "$WD" -name slang.uhdm -type f | sort)
rm -f /tmp/.r64census.$$
echo "census: $n databases scanned, NO_DUMP=$nodump, $cand CANDIDATE rows"
sort -rn "$OUT" | head -20
