#!/usr/bin/env bash
# r10uvm177repro/armjudge177.sh — JUDGE every boundary mover AGAINST GOLDEN.
# MEASUREMENT ONLY; the official uhdm-cmp is the sole judge and is run per arm
# per view by grid177.sh.  LHS is ALWAYS golden (Surelog).
#
#   armjudge177.sh <bound177 MOVERS file> <the arms dir the gate ran over> <outdir>
#
# The boundary gate reports that an arm's BYTES moved; it cannot say whether the
# move was TOWARD golden.  This script rebuilds each mover with grid177.sh —
# golden + pristine + patched, both views — and prints score177's verdict, whose
# MOVED-WRONG column is the number of cells that AGREED with golden and stopped
# agreeing.  Anything but 0 there convicts the law.
set -u
MOV=${1:?MOVERS file}; SRC=$(readlink -f "${2:?arms dir}"); OUT=$(readlink -f "${3:?outdir}")
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
mkdir -p "$OUT"
tot=0; bad=0
while read -r rel rest <&3; do
  [ -n "$rel" ] || continue
  f="$SRC/$rel"
  [ -f "$f" ] || { echo "SKIP-NOFILE $rel"; continue; }
  key=$(echo "$rel" | tr '/' '_')
  W="$OUT/$key.d"
  CT177CEN=${CT177CEN:-/tmp/r10uvm177_ct177cen} bash "$HERE/grid177.sh" "$f" "$PRIS" "$PATCHED" "$W" > "$W.log" 2>&1
  tot=$((tot+1))
  echo "#### $rel"
  grep '^cmp ' "$W/cmds.txt" | sed 's/^/    /'
  v=$(python3 "$HERE/score177.py" "$W" | grep '^== view')
  echo "$v" | sed 's/^/    /'
  # NO `bc` here: the first cut of this script piped through `bc`, which is
  # not installed, so the counter silently stayed 0 and the gate could not
  # convict.  awk sums the fields itself, and the SELFCHECK below proves the
  # summation can see a nonzero.
  n=$(printf '%s\n' "$v" | grep -o 'MOVED-WRONG=[0-9]*' | awk -F= '{s+=$2} END{print s+0}')
  sc=$(printf '%s\n' "$v" | grep -o 'positions=[0-9]*' | awk -F= '{s+=$2} END{print s+0}')
  [ "${sc:-0}" != 0 ] || { echo "    *** SELFCHECK FAILED: this arm scored no positions ***"; bad=$((bad+1)); }
  [ "${n:-0}" = 0 ] || { bad=$((bad+1)); echo "    *** MOVED-WRONG NONZERO ***"; }
done 3< <(grep -v '^RCDIFF' "$MOV" | cut -f1)
echo "ARMS-JUDGED=$tot  ARMS-WITH-MOVED-WRONG=$bad"
[ "$bad" = 0 ] || exit 5
