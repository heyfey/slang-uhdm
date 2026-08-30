#!/usr/bin/env bash
# r10v164 -- A-PRIORI MOVER PREDICTION from PRISTINE databases ONLY.
# MEASUREMENT ONLY.  Written and run BEFORE any patched database is compared.
#
# NECESSARY CONDITION for a database to move under
# S castOperandNeverBindsInCondWindow164: it must hold at least one reference
# that is (a) under a CAST, (b) homed in a CLASS-DEFINITION subroutine, and
# (c) currently BOUND.  Nothing else can lose a binding.  A database with none
# CANNOT move.  This is a SUPERSET predicate on purpose -- it does not read the
# condition column, so it over-predicts rather than under-predicts.
#
#   v164_predict.sh <pristine-workdir> <cen-bin> <out.txt>
set -u
WD=${1:?workdir}; CEN=${2:?cen}; OUT=${3:?out}
: > "$OUT"
n=0
while IFS= read -r db; do
  n=$((n+1))
  row=${db#"$WD"/}; row=${row%/slang.uhdm}
  c=$("$CEN" "$db" "P" 2>/dev/null | grep '^CAS|' | grep -v 'CAST=none' | grep 'class_defn' | grep -c '|BOUND$')
  [ "${c:-0}" -gt 0 ] && echo "CAND $row castbound=$c" >> "$OUT"
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- scanned=$n candidates=$(grep -c '^CAND' "$OUT"; true)" >> "$OUT"
