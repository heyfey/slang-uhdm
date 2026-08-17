#!/usr/bin/env bash
# r10buvm8repro/predict8.sh — PREDICT THE MOVERS BEFORE COMPARING BYTES.
#
#   usage: predict8.sh <pristine_workdir_root> > predicted.txt
#
# The law fires on exactly the cell
#   func_call | ELABPKG/RETTOP/PKGFN/BOUND | {ref_obj,bit_select,part_select,
#                                             indexed_part_select,constant,operation}
# so a database with ZERO rows in that cell CANNOT move, and a database with any
# is a predicted mover.  The elab-twin half of the law (`stampTf8`) re-points an
# ALREADY-stamped actual, so a `TS` row in the same cell predicts a mover too —
# which is why the count printed is TS+noTS, not just noTS.
#
# GUARD: a database the instrument cannot restore is printed as RESTORE_FAIL and
# COUNTED, never skipped -- a predictor that reached nothing must not read as
# "nothing will move".
set -u
W=${1:?pristine workdir root}
CEN=${R10BUVM8CEN:-/tmp/r10buvm8cen}
[ -x "$CEN" ] || { echo "FATAL: no census instrument at $CEN"; exit 3; }
n=0; pred=0; fail=0
while read -r db; do
  rel=${db#$W/}
  out=$("$CEN" "$db" "$rel" 2>/dev/null)
  if grep -q '^RESTORE_FAIL' <<<"$out"; then echo "RESTORE_FAIL $rel"; fail=$((fail+1)); continue; fi
  c=$(awk '$1=="CELL" && $3 ~ /^func_call\|ELABPKG\/RETTOP\/PKGFN\/BOUND\|(ref_obj|bit_select|part_select|indexed_part_select|constant|operation)\|/ {s+=$4} END{print s+0}' <<<"$out")
  n=$((n+1))
  if [ "$c" -gt 0 ]; then echo "PREDICT_MOVER $rel cells=$c"; pred=$((pred+1)); fi
done < <(find "$W" -name slang.uhdm | sort)
echo "-- databases=$n PREDICTED_MOVERS=$pred RESTORE_FAIL=$fail"
