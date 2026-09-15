#!/bin/bash
# r11u43 — run OUR exporter over every grid arm with an EXPLICIT binary, record
# rc.  BIN is mandatory: the harness silently defaults SLANG_UHDM to the
# main-tree binary, so nothing here reads that variable.
BIN=${BIN:?set BIN to the frozen binary}
ROOT=${1:-/tmp/r11u43_g/grid}
TAG=${2:-PRIS}
OUT=${3:-/tmp/r11u43_g/OURS.$TAG.rc.txt}
: > "$OUT"
for d in "$ROOT"/*/; do
  a=$(basename "$d")
  o="$d/$TAG.uhdm"
  rm -f "$o"
  ( cd "$d" && "$BIN" dut.sv --single-unit -o "$o" > "su.$TAG.log" 2>&1 )
  rc=$?
  db=NO; [ -f "$o" ] && db=YES
  printf '%s rc=%s db=%s bin=%s\n' "$a" "$rc" "$db" "$BIN" >> "$OUT"
done
cat "$OUT"
