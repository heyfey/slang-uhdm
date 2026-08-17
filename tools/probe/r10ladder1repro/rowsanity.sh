#!/bin/bash
# r10ladder1/rowsanity.sh — GATE 3: ctladder's rung #1 must BE the official head.
#
# The whole instrument rests on one claim: rung 1 of the ladder is exactly what
# the official `uhdm-cmp` reports.  That claim is not argued here, it is
# DIFFED: `ctladder --head1` reproduces uhdm-cmp's own output path (the same
# `decompile` of `m_failedLhs` / `m_failedRhs`), and this script requires the
# two programs' stderr to be BYTE IDENTICAL for every row.
#
#   usage: rowsanity.sh <workdir> <outdir> <mode:name> [...]
#
# GUARDS: golden path from the row's own cmds.txt; both sides existence-checked;
# a row that produces an EMPTY head file is a FAIL, not a pass (uhdm-cmp exits 0
# when an input is missing, and an empty diff of two empty files proves nothing).
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
LAD=${CTLADDER:-$(dirname "$0")/ctladder}
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
[ -x "$LAD" ] || { echo "FATAL: no ctladder at $LAD"; exit 3; }
mkdir -p "$OUT" || exit 1
pass=0; fail=0
printf "%-9s %-14s %10s %10s %s\n" MODE TEST CMPBYTES LADBYTES VERDICT
for spec in "$@"; do
  mode=${spec%%:*}; n=${spec#*:}
  for d in "$WD/$mode/$n"-*/; do
    [ -d "$d" ] || continue
    O=$d/slang.uhdm
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      printf "%-9s %-14s %10s %10s %s\n" "$mode" "$n" - - SKIP-NOFILE; fail=$((fail+1)); continue
    fi
    A=$OUT/head1_${mode}_${n}.cmp; B=$OUT/head1_${mode}_${n}.lad
    "$CMP" "$G" "$O" 2> "$A" > /dev/null; arc=$?
    "$LAD" "$G" "$O" --head1 2> "$B" > /dev/null; brc=$?
    sa=$(wc -c < "$A"); sb=$(wc -c < "$B")
    if [ "$sa" -eq 0 ]; then v="FAIL-EMPTY-HEAD"; fail=$((fail+1))
    elif cmp -s "$A" "$B"; then v="MATCH(rc $arc/$brc)"; pass=$((pass+1))
    else v="MISMATCH"; fail=$((fail+1)); fi
    printf "%-9s %-14s %10s %10s %s\n" "$mode" "$n" "$sa" "$sb" "$v"
  done
done
echo "-- MATCH=$pass FAIL=$fail"
[ "$fail" -eq 0 ] || exit 1
