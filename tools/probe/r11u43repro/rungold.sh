#!/bin/bash
# r11u43 — run the canonical v1.87 Surelog over every grid arm, record rc.
# MEASUREMENT ONLY.  Every arm records rc; a compile failure teaches
# error-recovery, not golden.
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
ROOT=${1:-/tmp/r11u43_g/grid}
OUT=${2:-/tmp/r11u43_g/GOLD.rc.txt}
: > "$OUT"
for d in "$ROOT"/*/; do
  a=$(basename "$d")
  ( cd "$d" && rm -rf slpp_all && "$SL" -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1 )
  rc=$?
  err=$(grep -c '\[ERR' "$d/sl.log" 2>/dev/null); err=${err:-0}
  fat=$(grep -c '\[FTL' "$d/sl.log" 2>/dev/null); fat=${fat:-0}
  db=NO; [ -f "$d/slpp_all/surelog.uhdm" ] && db=YES
  printf '%s rc=%s ERR=%s FTL=%s db=%s\n' "$a" "$rc" "$err" "$fat" "$db" >> "$OUT"
done
cat "$OUT"
