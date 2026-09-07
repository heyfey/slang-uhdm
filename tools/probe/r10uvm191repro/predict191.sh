#!/usr/bin/env bash
# r10uvm191repro/predict191.sh — THE A-PRIORI MOVER PREDICTION, from PRISTINE
# BYTES ALONE.  MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# For every row of a COMPLETED PRISTINE sweep workdir it reads the row's OWN
# golden (out of the row's `cmds.txt`, so the wrong golden can never be
# compared) and the row's pristine database, and asks `ct191hpb pred` the LAW's
# question of that pair:
#
#   is there a hier_path BASE under a DYNAMIC-ARRAY `new[...]` ARGUMENT that
#   GOLDEN binds and the PRISTINE database leaves BARE?
#
# A row with no such key CANNOT move — the law only ever fills such a base's
# `vpiActual`.  The predicate is a SUPERSET of the shipped gate (a database
# cannot say whether a listing is a WILDCARD-import clone or an EXPLICIT-import
# copy, and it asks nothing about the symbol half), so it can OVER-name and
# never UNDER-name.
#
#   usage: CT191=<ct191hpb> predict191.sh <PRISTINE workdir> <out.txt>
#
# LISTED / PROCESSED / NOGOLDEN are asserted in the out file, so a row that was
# silently skipped can never read as "cannot move".  Children read the file
# list on fd 3 and take </dev/null, the ops trap RESUME §9 names.
set -u
WD=${1:?pristine workdir}
OUT=${2:?out file}
CEN=${CT191:-/tmp/r10uvm191_bin/ct191hpb}
[ -x "$CEN" ] || { echo "FATAL: no ct191hpb at $CEN"; exit 3; }
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
