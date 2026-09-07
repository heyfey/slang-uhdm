#!/usr/bin/env bash
# r10uvm193repro/predict193.sh — THE A-PRIORI MOVER PREDICTION, from PRISTINE
# BYTES ALONE.  MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# For every row of a COMPLETED PRISTINE sweep workdir it reads the row's OWN
# golden (out of the row's `cmds.txt`, so the wrong golden can never be
# compared) and the row's pristine database, and asks `ct193arg pred` the LAW's
# question of that pair:
#
#   is there an ARGUMENT of a method call written on a receiver where GOLDEN's
#   `vpiActual` is a MINT (a variable parented at the call) and the PRISTINE
#   database's is not?
#
# A row with no such key CANNOT move — the law only ever writes such an
# argument's `vpiActual`.  The predicate is a SUPERSET of the shipped gate (a
# database cannot say whether a listing is a WILDCARD-import clone or an
# EXPLICIT-import copy, it asks nothing about the receiver's own kind and
# nothing about the `override` test), so it can OVER-name and never
# UNDER-name.
#
#   usage: CT193=<ct193arg> predict193.sh <PRISTINE workdir> <out.txt>
#
# LISTED / PROCESSED / NOGOLDEN are asserted in the out file, so a row that was
# silently skipped can never read as "cannot move".  Children read the file
# list on fd 3 and take </dev/null, the ops trap RESUME §9 names.
set -u
WD=${1:?pristine workdir}
OUT=${2:?out file}
CEN=${CT193:-/tmp/r10uvm193_bin/ct193arg}
[ -x "$CEN" ] || { echo "FATAL: no ct193arg at $CEN"; exit 3; }
: > "$OUT"
listed=0; processed=0; nogolden=0; predicted=0; cells=0
while IFS= read -r db <&3; do
  listed=$((listed+1))
  d=$(dirname "$db")
  rel=${d#$WD/}
  C="$d/cmds.txt"
  G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then
    echo "NOGOLDEN $rel" >> "$OUT"; nogolden=$((nogolden+1)); continue
  fi
  n=$("$CEN" pred "$G" "$db" </dev/null 2>/dev/null |
        sed -n 's/^PREDICTED_CELLS=//p' | tail -1)
  processed=$((processed+1))
  if [ "${n:-0}" -gt 0 ]; then
    echo "PREDICT $rel cells=$n" >> "$OUT"
    predicted=$((predicted+1)); cells=$((cells+n))
  fi
done 3< <(find "$WD" -name slang.uhdm | sort)
echo "LISTED=$listed PROCESSED=$processed NOGOLDEN=$nogolden PREDICTED=$predicted CELLS=$cells" >> "$OUT"
tail -1 "$OUT"
