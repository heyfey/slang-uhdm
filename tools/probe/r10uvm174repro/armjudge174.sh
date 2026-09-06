#!/usr/bin/env bash
# r10uvm174repro/armjudge174.sh — RE-MEASURE EVERY BOUNDARY MOVER AGAINST GOLDEN.
# MEASUREMENT ONLY; the official ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole
# judge.  LHS is ALWAYS golden (Surelog).
#
#   armjudge174.sh <bound174out/MOVERS> <arm tree root> <outdir>
#
# bound174.sh proves WHICH committed arms this pass's law moved; it cannot say
# whether they moved the right way.  This driver rebuilds each mover with
# Surelog (both views) and scores the pristine and patched databases against
# that golden with score174.py, span-blind (no generated Compare reads a span)
# and multiset (a copy-count difference must not be hidden).
#
# The verdict a landing needs from every row is AWAY-GOLDEN=0.  A row whose
# golden holds NO PKGDEF cell is printed EMPTY-GOLDEN and COUNTED: it moved for
# a reason this census cannot see, and it is reported, not swallowed.  The
# official cmp line counts for both binaries are printed beside it, because
# they are the acceptance number.
set -u
MOV=${1:?MOVERS file}
SRC=$(readlink -f "${2:?arm tree}")
OUT=$(readlink -f "${3:?outdir}")
SELF=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
n=0; away=0; empty=0; cmpworse=0; skipped=0
printf "%-46s %-9s %-9s %s\n" ARM CMP-a CMP-b VERDICT
while IFS=$'\t' read -r rel rest; do
  case "$rel" in RCDIFF*) echo "RC-DIFF ROW: $rel $rest"; continue;; esac
  f="$SRC/$rel"
  [ -f "$f" ] || { echo "MISSING $rel"; skipped=$((skipped+1)); continue; }
  key=$(echo "$rel" | tr '/' '_')
  W="$OUT/$key"
  bash "$SELF/grid174.sh" "$f" "${PRIS:?}" "${PATCHED:?}" "$W" > "$W.grid.log" 2>&1
  ca=$(grep '^cmp .* a def' "$W/cmds.txt" | sed 's/.*lines=\([0-9]*\).*/\1/')
  cb=$(grep '^cmp .* b def' "$W/cmds.txt" | sed 's/.*lines=\([0-9]*\).*/\1/')
  s=$(python3 "$SELF/score174.py" "$W" --only PKGDEF --nospan 2>&1 | tail -1)
  v=$s
  case "$s" in *"AWAY-GOLDEN=0 "*) ;; *) away=$((away+1)); v="AWAY!! $s";; esac
  case "$s" in *"EMPTY-GOLDEN-VIEWS=2"*) empty=$((empty+1)); v="EMPTY-GOLDEN (no PKGDEF cell in golden) $s";; esac
  if [ -n "$ca" ] && [ -n "$cb" ] && [ "$cb" -gt "$ca" ] 2>/dev/null; then
    cmpworse=$((cmpworse+1)); v="CMP-GREW $v"
  fi
  printf "%-46s %-9s %-9s %s\n" "$rel" "${ca:--}" "${cb:--}" "$v"
  rm -f "$W"/*.uhdm; rm -rf "$W"/g_def "$W"/g_elab
  n=$((n+1))
done < "$MOV"
echo "-- arms judged=$n  AWAY-GOLDEN rows=$away  EMPTY-GOLDEN rows=$empty  CMP-GREW rows=$cmpworse  MISSING=$skipped"
