#!/usr/bin/env bash
# r10rgg9/run_grid9.sh -- REAL SURELOG (golden) + any number of slang binaries
# over every grid cell; gridscan reads each side's per-site shapes.
#
#   usage: run_grid.sh <outdir> [<bin> <label> ...]
#
# GUARDS: a cell whose Surelog run produced NO database prints NODB and is
# COUNTED; a slang run that produced no file prints NOSLANG and is COUNTED.  A
# cell that reaches neither side must never read as agreement.
set -u
ROOT=$(cd "$(dirname "$0")" && pwd)
OUT=${1:?outdir}
shift || true
SL=$HOME/git-repos/Surelog/build/bin/surelog
SCAN=${GRIDSCAN:-/tmp/r10rgg9_gridscan}
[ -x "$SL" ] || { echo "FATAL: no surelog at $SL"; exit 3; }
[ -x "$SCAN" ] || { echo "FATAL: no gridscan at $SCAN"; exit 3; }
mkdir -p "$OUT"
nodb=0; noslang=0; cells=0
args=("$@")
for d in "$ROOT"/cells/*/; do
  c=$(basename "$d")
  w=$OUT/$c
  mkdir -p "$w"
  cells=$((cells+1))
  if [ ! -s "$w/gold.sites" ]; then
    (cd "$d" && "$SL" -parse dut.sv -mt 0 -mp 0 -o "$w" > "$w/sl.log" 2>&1)
    g=$(ls "$w"/slpp_all/*.uhdm 2>/dev/null | head -1)
    if [ -z "$g" ]; then echo "NODB $c"; nodb=$((nodb+1)); : > "$w/gold.sites"; continue; fi
    "$SCAN" "$g" > "$w/gold.sites" 2> "$w/gold.err"
  fi
  k=0
  while [ $k -lt ${#args[@]} ]; do
    bin=${args[$k]}; lbl=${args[$((k+1))]}
    (cd "$d" && "$bin" dut.sv --single-unit -o "$w/$lbl.uhdm" > "$w/$lbl.log" 2>&1)
    if [ -s "$w/$lbl.uhdm" ]; then
      "$SCAN" "$w/$lbl.uhdm" > "$w/$lbl.sites" 2> "$w/$lbl.err"
    else
      echo "NOSLANG $c $lbl"; noslang=$((noslang+1)); : > "$w/$lbl.sites"
    fi
    k=$((k+2))
  done
done
echo "-- cells=$cells NODB=$nodb NOSLANG=$noslang"
