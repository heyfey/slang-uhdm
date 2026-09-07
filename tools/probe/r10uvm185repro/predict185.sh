#!/usr/bin/env bash
# r10uvm185 — PREDICT THE BYTE MOVERS BY NAME, FROM THE PRISTINE DATABASES
# ALONE, before the patched sweep is read.  MEASUREMENT ONLY.
#
#   usage: CEN=<ct185cen> ./predict185.sh <pristine-sweep-workdir> <out-prefix>
#
# NO GOLDEN IS OPENED HERE ON PURPOSE: a prediction read off the goldens would
# name only the cells that DISAGREE today and would be blind to a cell the law
# moves AWAY from an answer that already agreed.
#
# THE PREDICATE, and why it is an OVER-approximation on the safe side:
#
#   § externProtoRetVarKindIsPrototypeCompile185 can only change the VARIABLE
#   CLASS of a return variable that
#     (1) belongs to a CLASS-BODY PROTOTYPE listing — parent is a `class_defn`
#         and the function has NO `Stmt` (that is the only listing where the
#         new gate's `protoOf` is set), and
#     (2) is TODAY one of the two classes
#         § classTdLocalVarKindFollowsCompileOrder10 hands back when it does NOT
#         resolve — `class_var` or `ref_var` — because the change can only turn
#         a NON-resolving answer into a resolving one, and
#     (3) whose `Typespec()->Actual` is NOT a `class_typespec`: when the
#         resolved answer would itself be a `class_var` the cell cannot move.
#
# Everything outside that set is provably untouched, so a database with ZERO
# such rows CANNOT move.  A database WITH such rows is a CANDIDATE, not a
# prediction of movement — the resolved answer may equal the current one.  The
# candidate list is therefore the UPPER BOUND the byte-mover gate is scored
# against, and the README names both it and the actual movers.
set -u
CEN=${CEN:?set CEN to the ct185cen binary}
WD=${1:?pristine sweep workdir}
OUT=${2:?output prefix}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT.rows"
: > "$OUT.dbs"
n=0
while read -r db <&3; do
  n=$((n+1))
  rel=${db#$WD/}
  rel=${rel%/slang.uhdm}
  "$CEN" "$db" 2>/dev/null |
    awk -v R="$rel" -F'\t' '
      $1=="FN" && $4=="0" && $5 ~ /^class_defn:/ &&
      ($6=="class_var" || $6=="ref_var") && $8!="class_typespec" && $8!="-" {
        print R "\t" $2 "\t" $3 "\t" $6 "\t" $8 "\t" $9
      }' >> "$OUT.rows"
done 3< <(find "$WD" -name slang.uhdm | sort)
awk -F'\t' '{c[$1]++} END {for (k in c) printf "%s\t%d\n", k, c[k]}' "$OUT.rows" |
  sort > "$OUT.dbs"
echo "SCANNED=$n CANDIDATE_ROWS=$(grep -c . "$OUT.rows" || true)" \
     "CANDIDATE_DBS=$(grep -c . "$OUT.dbs" || true)"
