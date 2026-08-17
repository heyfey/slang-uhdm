#!/usr/bin/env bash
# vrgg6: run REAL SURELOG + a slang-uhdm binary over a cell directory tree.
set -u
CELLS=${1:?cells}
OUT=${2:?out}
BIN=${3:-}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
SCAN=$(cd "$(dirname "$0")" && pwd)/../r10rgg6repro/dumpscan.py
mkdir -p "$OUT"
for d in "$CELLS"/*/; do
  c=$(basename "$d"); w=$OUT/$c; mkdir -p "$w"
  if [ ! -f "$w/gold.dump" ]; then
    (cd "$d" && "$SL" -parse dut.sv -mt 0 -mp 0 -o "$w" > "$w/sl.log" 2>&1)
    g=$(ls "$w"/slpp_all/*.uhdm 2>/dev/null | head -1)
    if [ -z "$g" ]; then echo "NODB $c"; continue; fi
    "$DUMP" "$g" > "$w/gold.dump" 2>&1
  fi
  python3 "$SCAN" "$w/gold.dump" calls > "$w/gold.calls.tsv"
  if [ -n "$BIN" ]; then
    (cd "$d" && "$BIN" dut.sv --single-unit -o "$w/slang.uhdm" > "$w/su.log" 2>&1)
    echo "$c rc=$?" >> "$OUT/rc.txt"
    if [ -f "$w/slang.uhdm" ]; then
      "$DUMP" "$w/slang.uhdm" > "$w/ours.dump" 2>&1
      python3 "$SCAN" "$w/ours.dump" calls > "$w/ours.calls.tsv"
    else echo "NOSLANG $c"; : > "$w/ours.calls.tsv"; fi
  fi
done
