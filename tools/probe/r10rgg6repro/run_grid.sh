#!/usr/bin/env bash
# r10rgg6/run_grid.sh -- run REAL SURELOG (golden) and, optionally, a
# slang-uhdm binary over every grid cell, and score both with dumpscan.py.
#
#   usage: run_grid.sh <outdir> [slang-uhdm-binary]
#
# The Surelog argv is verify_golden.py's `default` mode for a one-source test:
#   surelog -parse dut.sv -mt 0 -mp 0 -o <work>
# and slang-uhdm's mirror is
#   slang-uhdm dut.sv --single-unit -o <work>/slang.uhdm
# GUARD: a cell whose Surelog run produces NO database is printed NODB and
# COUNTED -- an unmeasured cell must never read as agreement.
set -u
ROOT=$(cd "$(dirname "$0")" && pwd)
OUT=${1:?outdir}
BIN=${2:-}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT"
for d in "$ROOT"/cells/*/; do
  c=$(basename "$d")
  w=$OUT/$c
  mkdir -p "$w"
  if [ ! -f "$w/gold.dump" ]; then
    (cd "$d" && "$SL" -parse dut.sv -mt 0 -mp 0 -o "$w" > "$w/sl.log" 2>&1)
    g=$(ls "$w"/slpp_all/*.uhdm 2>/dev/null | head -1)
    if [ -z "$g" ]; then echo "NODB $c"; continue; fi
    "$DUMP" "$g" > "$w/gold.dump" 2>&1
  fi
  python3 "$ROOT/dumpscan.py" "$w/gold.dump" calls > "$w/gold.calls.tsv"
  python3 "$ROOT/dumpscan.py" "$w/gold.dump" params > "$w/gold.params.tsv"
  if [ -n "$BIN" ]; then
    (cd "$d" && "$BIN" dut.sv --single-unit -o "$w/slang.uhdm" > "$w/su.log" 2>&1)
    if [ -f "$w/slang.uhdm" ]; then
      "$DUMP" "$w/slang.uhdm" > "$w/ours.dump" 2>&1
      python3 "$ROOT/dumpscan.py" "$w/ours.dump" calls > "$w/ours.calls.tsv"
    else
      echo "NOSLANG $c"
      : > "$w/ours.calls.tsv"
    fi
  fi
done
echo "-- cells=$(ls -d "$ROOT"/cells/*/ | wc -l)"
