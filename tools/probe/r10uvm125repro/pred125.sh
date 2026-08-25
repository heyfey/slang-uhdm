#!/usr/bin/env bash
# r10uvm125 — A-PRIORI MOVER PREDICTOR.  Scans every PRISTINE database in a
# verify_golden workdir and reports the ones holding at least one ONE-OPERAND
# operation(vpiAssignmentOp=82) in a tf_call argument slot — the object this
# pass removes.  Those, and only those, may move.
# MEASUREMENT ONLY — the official uhdm-cmp is the judge.
#   usage: CEN125=.. pred125.sh <workdir> [more workdirs...]
set -u
CEN=${CEN125:?set CEN125}
tot=0; hit=0
for WD in "$@"; do
  while IFS= read -r db; do
    tot=$((tot+1))
    n=$("$CEN" "$db" 2>/dev/null | grep -c 'op82 nops=1'; true)
    if [ "${n:-0}" -gt 0 ]; then
      hit=$((hit+1))
      echo "PREDICT $n $(echo "$db" | sed 's#.*/\([^/]*\)/\([^/]*\)/slang.uhdm#\1/\2#')"
    fi
  done < <(find "$WD" -name 'slang.uhdm' | sort)
done
echo "SCANNED=$tot PREDICTED_MOVERS=$hit"
