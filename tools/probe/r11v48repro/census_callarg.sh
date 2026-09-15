#!/bin/bash
# r11v48 — golden-only census of CALL ARGUMENTS across every cached golden.
OUT=${OUT:?}
FC=/tmp/v11u48_bin/fcarg48
: > $OUT
n=0
for g in /home/heyfey/.cache/slang-uhdm-goldens/*/golden.uhdm; do
  d=$(dirname $g)
  "$FC" "$g" 2>/dev/null | grep '^FC ' | sed "s|^|$(basename $d) |" >> $OUT
  n=$((n+1))
done
echo "GOLDENS $n"
echo "LINES $(wc -l < $OUT)"
