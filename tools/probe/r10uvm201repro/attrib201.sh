#!/usr/bin/env bash
# r10uvm201repro/attrib201.sh — THE ATTRIBUTION of every byte mover.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
# TWO INSTRUMENTS.
#
#  1. THE ORDER-BLIND SORTED DUMP DIFF.  RESUME §9: `Scoreboard/default` is a
#     ~50/50 COIN per invocation, so a raw dump diff reads as change even when
#     nothing moved.  Both databases are dumped, the workdir path (which the
#     dump embeds) is normalised away, both are SORTED, and the two are
#     diffed — a pure ORDER flip then scores zero lines.  This law is
#     ADDITIVE (it mints one `ref_typespec` on a folded Rhs constant and binds
#     it to the typespec the parameter ALREADY carries), so the load-bearing
#     number here is REMOVED: it must be 0 — nothing destroyed, nothing
#     re-spanned, nothing re-typed — and every ADDED line must belong to the
#     minted chain.  The `ADDED-THAT-ARE-NOT-typespec` counter is a screen, not
#     a verdict: the chain's own `|vpiParent:` / `|vpiActual:` /
#     `|vpiFullName:` / owning-`constant` context lines are legitimately not
#     typespec lines, so the added set is also printed in full.
#
#  2. THE Rhs/Lhs TYPESPEC-ASYMMETRY CELL COUNT (`ct201cen --pred`).  The law's
#     whole footprint is "how many `param_assign` cells carry a typespec on the
#     Lhs parameter and none on the folded Rhs constant" (RHSGAP), printed for
#     both databases together with the reverse class (LHSGAP), which must not
#     grow.
#
#   usage: CEN=<ct201cen> attrib201.sh <patched workdir> <pristine workdir> <outdir> <rel...>
set -u
PW=${1:?patched workdir}; RW=${2:?pristine workdir}; OUT=${3:?outdir}
shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${CEN:?set CEN to the built ct201cen}
mkdir -p "$OUT" || exit 3
tot=0; rem_tot=0; nonts=0
for rel in "$@"; do
  p="$PW/$rel"; r="$RW/$rel"
  key=$(echo "$rel" | tr '/' '_')
  if [ ! -f "$p" ] || [ ! -f "$r" ]; then echo "MISSING $rel"; continue; fi
  "$DUMP" "$p" 2>/dev/null | sed "s|$PW||g" | sort > "$OUT/$key.pat"
  "$DUMP" "$r" 2>/dev/null | sed "s|$RW||g" | sort > "$OUT/$key.pri"
  comm -13 "$OUT/$key.pri" "$OUT/$key.pat" > "$OUT/$key.added"
  comm -23 "$OUT/$key.pri" "$OUT/$key.pat" > "$OUT/$key.removed"
  add=$(wc -l < "$OUT/$key.added"); rem=$(wc -l < "$OUT/$key.removed")
  # CASE-INSENSITIVE: the dump writes `|vpiTypespec:` with a capital T, and a
  # case-sensitive count reported four of the new chain's own lines as
  # "not a typespec line".
  ns=$(grep -civ 'typespec' "$OUT/$key.added" || true)
  echo "$rel  ORDER-BLIND ADDED=$add REMOVED=$rem ADDED-THAT-ARE-NOT-typespec=$ns"
  sed 's/^/    ADDED    /' "$OUT/$key.added"   | sort | uniq -c | sort -rn | head -20
  sed 's/^/    REMOVED  /' "$OUT/$key.removed" | sort | uniq -c | sort -rn | head -20
  tot=$((tot+add+rem)); rem_tot=$((rem_tot+rem)); nonts=$((nonts+ns))
  echo "  Rhs/Lhs asymmetric param_assign cells: pristine [$("$CEN" --pred "$r" pri | awk '/^PREDSUM/{print $4, $5}')] -> patched [$("$CEN" --pred "$p" pat | awk '/^PREDSUM/{print $4, $5}')]"
done
echo "-- TOTAL sorted-diff lines=$tot REMOVED-TOTAL=$rem_tot ADDED-NOT-typespec=$nonts"
