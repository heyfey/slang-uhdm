#!/usr/bin/env bash
# r10uvm199repro/attrib199.sh — THE ATTRIBUTION of every byte mover.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
# TWO INSTRUMENTS.
#
#  1. THE ORDER-BLIND SORTED DUMP DIFF.  RESUME §9: `Scoreboard/default` is a
#     ~50/50 COIN per invocation, so a raw dump diff reads as change even when
#     nothing moved.  Both databases are dumped, the workdir path (which the
#     dump embeds) is normalised away, both are SORTED, and the two are
#     diffed — a pure ORDER flip then scores zero lines.  This law is
#     SUBTRACTIVE (it declines to build one `ref_typespec` and the
#     `int_typespec` behind it), so the load-bearing number here is ADDED: it
#     must be 0, i.e. nothing was created, re-spanned or re-typed, and every
#     REMOVED line must belong to the declined typespec chain.
#
#  2. THE TYPESPEC-ASYMMETRY CELL COUNT (`ct199cen --pred`).  The law's whole
#     footprint is "how many DEF-view materialized copies still carry a
#     `param_assign`-Lhs typespec their own `Parameters`-listing twin has
#     not got", printed for both databases.  It must go to 0.
#
#   usage: CEN=<ct199cen> attrib199.sh <patched workdir> <pristine workdir> <outdir> <rel...>
set -u
PW=${1:?patched workdir}; RW=${2:?pristine workdir}; OUT=${3:?outdir}
shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${CEN:?set CEN to the built ct199cen}
mkdir -p "$OUT" || exit 3
tot=0; add_tot=0; nonts=0
for rel in "$@"; do
  p="$PW/$rel"; r="$RW/$rel"
  key=$(echo "$rel" | tr '/' '_')
  if [ ! -f "$p" ] || [ ! -f "$r" ]; then echo "MISSING $rel"; continue; fi
  "$DUMP" "$p" 2>/dev/null | sed "s|$PW||g" | sort > "$OUT/$key.pat"
  "$DUMP" "$r" 2>/dev/null | sed "s|$RW||g" | sort > "$OUT/$key.pri"
  comm -13 "$OUT/$key.pri" "$OUT/$key.pat" > "$OUT/$key.added"
  comm -23 "$OUT/$key.pri" "$OUT/$key.pat" > "$OUT/$key.removed"
  add=$(wc -l < "$OUT/$key.added"); rem=$(wc -l < "$OUT/$key.removed")
  ns=$(grep -cv 'typespec' "$OUT/$key.removed" || true)
  echo "$rel  ORDER-BLIND ADDED=$add REMOVED=$rem REMOVED-THAT-ARE-NOT-typespec=$ns"
  sed 's/^/    REMOVED  /' "$OUT/$key.removed" | sort | uniq -c | sort -rn | head -20
  sed 's/^/    ADDED    /' "$OUT/$key.added"   | sort | uniq -c | sort -rn | head -20
  tot=$((tot+add+rem)); add_tot=$((add_tot+add)); nonts=$((nonts+ns))
  echo "  ts-asymmetric materialized cells: pristine $("$CEN" --pred "$r" pri | awk '/^PREDSUM/{print $4}') -> patched $("$CEN" --pred "$p" pat | awk '/^PREDSUM/{print $4}')"
done
echo "-- TOTAL sorted-diff lines=$tot ADDED-TOTAL=$add_tot REMOVED-NOT-typespec=$nonts"
