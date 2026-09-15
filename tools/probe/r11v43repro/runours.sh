#!/bin/bash
BIN=${BIN:?}; ROOT=${1:?}; TAG=${2:?}; OUT=${3:?}
: > "$OUT"
for d in "$ROOT"/*/; do
  a=$(basename "$d"); o="$d/$TAG.uhdm"; rm -f "$o"
  ( cd "$d" && env $EXTRA timeout 300 "$BIN" dut.sv --single-unit -o "$o" > "su.$TAG.log" 2>&1 )
  rc=$?
  db=NO; [ -f "$o" ] && db=YES
  printf '%s rc=%s db=%s bin=%s\n' "$a" "$rc" "$db" "$BIN" >> "$OUT"
done
cat "$OUT"
