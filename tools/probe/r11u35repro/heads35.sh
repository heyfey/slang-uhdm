#!/bin/bash
# r11u35 — print the ONE head per row, golden(LHS) vs ours(RHS).
# usage: heads.sh <workdir-root>
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
WD=${1:?workdir}
for d in $(find "$WD" -name slang.uhdm | sort); do
  dir=$(dirname "$d")
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$dir/cmds.txt" | head -1)
  [ -z "$g" ] && { echo "NOGOLD $dir"; continue; }
  mode=$(basename $(dirname "$dir")); nm=$(basename "$dir")
  out=$($CMP "$g/golden.uhdm" "$d" 2>&1)
  nh=$(printf '%s\n' "$out" | grep -c '^LHS:' ; true)
  echo "=== $nm [$mode] heads=$nh"
  printf '%s\n' "$out" | grep -A${N:-16} '^LHS:' | head -${M:-60}
done
