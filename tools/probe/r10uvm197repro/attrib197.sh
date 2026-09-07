#!/usr/bin/env bash
# r10uvm197repro/attrib197.sh — THE ATTRIBUTION of every byte mover.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
# TWO INSTRUMENTS, because one of them is weak for THIS law.
#
#  1. THE ORDER-BLIND SORTED DUMP DIFF.  RESUME §9: `Scoreboard/default` is a
#     ~50/50 COIN per invocation, so a raw dump diff reads as change even when
#     nothing moved.  Both databases are dumped, the workdir path (which the
#     dump embeds) is normalised away, both are SORTED, and the two are
#     diffed — a pure ORDER flip then scores zero lines.  For an ADDITIVE law
#     the load-bearing number here is REMOVED: it must be 0, i.e. nothing was
#     destroyed, re-spanned or re-typed.
#
#  2. THE ZERO-SIZE CELL COUNT (`ct197cen --pred`).  This law CREATES NOTHING
#     and DESTROYS NOTHING: it writes one integer onto constants that already
#     existed.  Its whole footprint is therefore "how many materialized-import
#     cells still carry vpiSize 0", printed for both databases.  Every ADDED
#     dump line must be a `|vpiSize:` line, and REMOVED must be 0.
#
#   usage: CEN=<ct197cen> attrib197.sh <patched workdir> <pristine workdir> <outdir> <rel...>
set -u
PW=${1:?patched workdir}; RW=${2:?pristine workdir}; OUT=${3:?outdir}
shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${CEN:?set CEN to the built ct197cen}
mkdir -p "$OUT" || exit 3
tot=0; rem_tot=0; nonsize=0
for rel in "$@"; do
  p="$PW/$rel"; r="$RW/$rel"
  key=$(echo "$rel" | tr '/' '_')
  if [ ! -f "$p" ] || [ ! -f "$r" ]; then echo "MISSING $rel"; continue; fi
  "$DUMP" "$p" 2>/dev/null | sed "s|$PW||g" | sort > "$OUT/$key.pat"
  "$DUMP" "$r" 2>/dev/null | sed "s|$RW||g" | sort > "$OUT/$key.pri"
  comm -13 "$OUT/$key.pri" "$OUT/$key.pat" > "$OUT/$key.added"
  comm -23 "$OUT/$key.pri" "$OUT/$key.pat" > "$OUT/$key.removed"
  add=$(wc -l < "$OUT/$key.added"); rem=$(wc -l < "$OUT/$key.removed")
  ns=$(grep -cv '|vpiSize:' "$OUT/$key.added" || true)
  echo "$rel  ORDER-BLIND ADDED=$add REMOVED=$rem ADDED-THAT-ARE-NOT-vpiSize=$ns"
  sed 's/^/    ADDED  /' "$OUT/$key.added" | sort | uniq -c | sort -rn | head -20
  tot=$((tot+add+rem)); rem_tot=$((rem_tot+rem)); nonsize=$((nonsize+ns))
  echo "  zero-size materialized cells: pristine $("$CEN" --pred "$r" pri | awk '/^PREDSUM/{print $4}') -> patched $("$CEN" --pred "$p" pat | awk '/^PREDSUM/{print $4}')"
done
echo "-- TOTAL sorted-diff lines=$tot REMOVED-TOTAL=$rem_tot ADDED-NOT-vpiSize=$nonsize"
