#!/usr/bin/env bash
# r10uvm196repro/attrib196.sh — THE ATTRIBUTION of every byte mover.
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
#  2. THE OBJECT-KIND CENSUS (`ct196cen --obj`).  The dump is a POOR
#     attribution instrument for a law that ADDS objects — a new parameter's
#     block repeats field names (`|vpiName:`, `|vpiParent:`) that occur
#     everywhere, so a line whitelist would attribute anything.  The honest
#     statement is at the OBJECT level: which UHDM kinds were created, and how
#     many.  Every kind whose count moves is printed with its delta, and the
#     law must account for each one by name.
#
#   usage: attrib196.sh <patched workdir> <pristine workdir> <outdir> <rel...>
set -u
PW=${1:?patched workdir}; RW=${2:?pristine workdir}; OUT=${3:?outdir}
shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${CEN:?set CEN to the built ct196cen}
mkdir -p "$OUT" || exit 3
tot=0; rem_tot=0
for rel in "$@"; do
  p="$PW/$rel"; r="$RW/$rel"
  key=$(echo "$rel" | tr '/' '_')
  if [ ! -f "$p" ] || [ ! -f "$r" ]; then echo "MISSING $rel"; continue; fi
  "$DUMP" "$p" 2>/dev/null | sed "s|$PW||g" | sort > "$OUT/$key.pat"
  "$DUMP" "$r" 2>/dev/null | sed "s|$RW||g" | sort > "$OUT/$key.pri"
  add=$(comm -13 "$OUT/$key.pri" "$OUT/$key.pat" | wc -l)
  rem=$(comm -23 "$OUT/$key.pri" "$OUT/$key.pat" | wc -l)
  echo "$rel  ORDER-BLIND ADDED=$add REMOVED=$rem"
  tot=$((tot+add+rem)); rem_tot=$((rem_tot+rem))
  "$CEN" --obj "$r" pri > "$OUT/$key.obj.pri" 2>&1
  "$CEN" --obj "$p" pat > "$OUT/$key.obj.pat" 2>&1
  echo "  object-kind deltas (patched - pristine), kinds that moved:"
  # OBJ rows are "OBJ <tag> <kind> <count>": join on the KIND (field 3)
  join -j 1 -o 0,1.2,2.2 \
    <(awk '$1=="OBJ"{print $3, $4}' "$OUT/$key.obj.pri" | sort -k1,1) \
    <(awk '$1=="OBJ"{print $3, $4}' "$OUT/$key.obj.pat" | sort -k1,1) \
    | awk '$2!=$3{printf "    %-24s %8d -> %8d  (%+d)\n",$1,$2,$3,$3-$2}'
  # a kind present on one side only would be dropped by the join above
  comm -3 <(awk '$1=="OBJ"{print $3}' "$OUT/$key.obj.pri" | sort) \
          <(awk '$1=="OBJ"{print $3}' "$OUT/$key.obj.pat" | sort) \
    | sed 's/^/    KIND-ONLY-ONE-SIDE /'
  grep '^OBJTOT' "$OUT/$key.obj.pri" "$OUT/$key.obj.pat" | sed 's/^/    /'
done
echo "-- TOTAL sorted-diff lines=$tot REMOVED-TOTAL=$rem_tot"
