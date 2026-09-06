#!/usr/bin/env bash
# r10uvm175 — THE A-PRIORI MOVER PREDICTION, made from the PRISTINE databases
# ALONE, BEFORE the patched sweep runs.  MEASUREMENT ONLY.
#
#   CEN=<ct175cen> predict175.sh <verify_golden workdir> [<label>]
#
# `ct175cen --pred` is a deliberate SUPERSET of the law's site (it cannot see
# slang's bound receiver), so a row that prints NOTHING here CANNOT move.  Rows
# that print candidates are the only ones allowed to appear as byte movers.
set -u
WD=${1:?workdir}
LBL=${2:-}
CEN=${CEN:-/tmp/r10uvm175_bin/ct175cen}
[ -x "$CEN" ] || { echo "FATAL: no ct175cen at $CEN"; exit 3; }
scanned=0; skip=0; hits=0
while IFS= read -r db; do
  scanned=$((scanned+1))
  [ -s "$db" ] || { skip=$((skip+1)); continue; }
  n=$("$CEN" "$db" --pred 2>/dev/null | sed -n 's/^-- PRED cells=//p')
  case "$n" in ''|0) continue;; esac
  hits=$((hits+1))
  echo "CAND $n ${db#$WD/}"
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- PREDICT $LBL scanned=$scanned SKIP=$skip ROWS-WITH-CANDIDATES=$hits"
