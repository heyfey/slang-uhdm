#!/usr/bin/env bash
# r10rgg7/run_grid.sh -- REAL SURELOG (golden) + optional slang-uhdm binaries
# over every grid cell; armscan.py reads WHICH ARM each side elaborated.
#
#   usage: run_grid.sh <outdir> [<bin1> <label1> [<bin2> <label2> ...]]
#
# The argv mirrors verify_golden.py's `default` mode for a one-source test.
# GUARDS: a cell whose Surelog run produced NO database prints NODB and is
# COUNTED; a slang run that produced no file prints NOSLANG and is COUNTED.
set -u
ROOT=$(cd "$(dirname "$0")" && pwd)
OUT=${1:?outdir}
shift || true
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT"
nodb=0; noslang=0; cells=0
for d in "$ROOT"/cells/*/; do
  c=$(basename "$d")
  w=$OUT/$c
  mkdir -p "$w"
  cells=$((cells+1))
  if [ ! -f "$w/gold.arms" ]; then
    (cd "$d" && "$SL" -parse dut.sv -mt 0 -mp 0 -o "$w" > "$w/sl.log" 2>&1)
    g=$(ls "$w"/slpp_all/*.uhdm 2>/dev/null | head -1)
    if [ -z "$g" ]; then echo "NODB $c"; nodb=$((nodb+1)); continue; fi
    "$DUMP" "$g" > "$w/gold.dump" 2>&1
    python3 "$ROOT/armscan.py" "$w/gold.dump" > "$w/gold.arms" 2>&1 || true
  fi
  i=0
  while [ $# -gt $((i+1)) ] || { [ $# -gt 0 ] && [ $((i+1)) -lt $# ]; }; do
    break
  done
  set -- "$@"
  n=1
  args=("$@")
  k=0
  while [ $k -lt ${#args[@]} ]; do
    bin=${args[$k]}; lbl=${args[$((k+1))]}
    (cd "$d" && "$bin" dut.sv --single-unit -o "$w/$lbl.uhdm" > "$w/$lbl.log" 2>&1)
    if [ -f "$w/$lbl.uhdm" ]; then
      "$DUMP" "$w/$lbl.uhdm" > "$w/$lbl.dump" 2>&1
      python3 "$ROOT/armscan.py" "$w/$lbl.dump" > "$w/$lbl.arms" 2>&1 || true
    else
      echo "NOSLANG $c $lbl"; noslang=$((noslang+1)); : > "$w/$lbl.arms"
    fi
    k=$((k+2))
  done
done
echo "-- cells=$cells NODB=$nodb NOSLANG=$noslang"
