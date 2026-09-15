#!/bin/bash
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
ROOT=${1:?}; OUT=${2:?}
: > "$OUT"
for d in "$ROOT"/*/; do
  a=$(basename "$d")
  ( cd "$d" && rm -rf slpp_all && timeout 300 "$SL" -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1 )
  rc=$?
  err=$(grep -c '\[ERR' "$d/sl.log" 2>/dev/null); err=${err:-0}
  fat=$(grep -c '\[FTL' "$d/sl.log" 2>/dev/null); fat=${fat:-0}
  db=NO; [ -f "$d/slpp_all/surelog.uhdm" ] && db=YES
  printf '%s rc=%s ERR=%s FTL=%s db=%s\n' "$a" "$rc" "$err" "$fat" "$db" >> "$OUT"
done
cat "$OUT"
