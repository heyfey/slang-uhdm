#!/bin/bash
# r10ladder1/detcheck.sh — GATE 4: two runs of a row give the SAME ladder.
#
# The ladder is a fixpoint iteration over an unordered_set (`m_visited`) and a
# bisection over a pool that must therefore be ordered by UhdmId and never by
# ADDRESS.  This script re-runs each row and diffs the ladders with the
# wall-clock field stripped (it is the one field that is allowed to differ);
# every other byte, including every mask decision, must be identical.
#
#   usage: detcheck.sh <workdir> <outdir> <mode:name> [...]
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
LAD=${CTLADDER:-$(dirname "$0")/ctladder}
[ -x "$LAD" ] || { echo "FATAL: no ctladder at $LAD"; exit 3; }
mkdir -p "$OUT" || exit 1
MAX=${MAX:-20000}; BUDGET=${BUDGET:-1800}
ok=0; bad=0
printf "%-9s %-14s %8s %s\n" MODE TEST RUNGS VERDICT
for spec in "$@"; do
  mode=${spec%%:*}; n=${spec#*:}
  for d in "$WD/$mode/$n"-*/; do
    [ -d "$d" ] || continue
    O=$d/slang.uhdm
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      printf "%-9s %-14s %8s %s\n" "$mode" "$n" - SKIP-NOFILE; bad=$((bad+1)); continue
    fi
    for k in a b; do
      "$LAD" "$G" "$O" --max="$MAX" --budget="$BUDGET" 2>&1 |
        sed 's/ secs=[0-9.]*//' > "$OUT/det_${mode}_${n}.$k"
    done
    r=$(grep -c '^RUNG' "$OUT/det_${mode}_${n}.a")
    if diff -q "$OUT/det_${mode}_${n}.a" "$OUT/det_${mode}_${n}.b" >/dev/null; then
      printf "%-9s %-14s %8s %s\n" "$mode" "$n" "$r" IDENTICAL; ok=$((ok+1))
    else
      printf "%-9s %-14s %8s %s\n" "$mode" "$n" "$r" \
        "DIFFERS($(diff "$OUT/det_${mode}_${n}.a" "$OUT/det_${mode}_${n}.b" | grep -c '^[<>]') lines)"
      bad=$((bad+1))
    fi
  done
done
echo "-- IDENTICAL=$ok NOT=$bad"
[ "$bad" -eq 0 ] || exit 1
