#!/bin/bash
# r10uvm159 — run ct159join over EVERY (golden, ours) pair in a verify_golden
# workdir.  MEASUREMENT ONLY.  LHS is ALWAYS golden.
#
# GUARDS: the golden path comes out of the arm's OWN cmds.txt (never guessed);
# a missing side prints SKIP and is COUNTED; the scratch key is the arm's
# RELATIVE path (three different tests are called `dut.sv`).
#
#   usage: cen159.sh <workdir> <outfile> [--list]
set -u
WD=${1:?workdir}
OUT=${2:?outfile}
LIST=${3:-}
BIN=${BIN:-/tmp/wt_r10uvm159/tools/probe/r10uvm159repro/ct159join}
[ -x "$BIN" ] || { echo "FATAL: no $BIN"; exit 3; }
: > "$OUT"
n=0; skip=0
for c in "$WD"/*/*/cmds.txt; do
  [ -f "$c" ] || continue
  d=$(dirname "$c")
  rel=${d#$WD/}
  o=$d/slang.uhdm
  g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$c" | head -1)
  [ -n "$g" ] && [ -d "$g" ] && g=$g/golden.uhdm
  if [ -z "$g" ] || [ ! -f "$g" ] || [ ! -f "$o" ]; then
    echo "SKIP $rel" >> "$OUT"; skip=$((skip+1)); continue
  fi
  timeout 600 "$BIN" "$g" "$o" --tag="$rel" $LIST >> "$OUT" 2>&1
  n=$((n+1))
done
echo "-- pairs=$n skipped=$skip" >> "$OUT"
echo "-- pairs=$n skipped=$skip"
