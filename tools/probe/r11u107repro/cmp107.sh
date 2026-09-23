#!/bin/bash
# cmp107.sh <workdir-root> [test-regex]: per test dir, uhdm-cmp golden (LHS) vs ours;
# prints mode/test, cmp line count, head count, and the head block (first 8 lines).
WD=${1:?workdir}; RE=${2:-.}
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
for c in $(find "$WD" -name cmds.txt | sort); do
  d=$(dirname "$c"); t=$(basename "$d"); m=$(basename "$(dirname "$d")")
  echo "$t" | grep -qE "$RE" || continue
  g=$(grep -o 'golden cache hit [^)]*' "$c" | awk '{print $4}')/golden.uhdm
  [ -f "$d/slang.uhdm" ] || { echo "$m $t NO-OURS"; continue; }
  "$CMP" "$g" "$d/slang.uhdm" > "$d/cmp.log" 2>&1; rc=$?
  n=$(wc -l < "$d/cmp.log"); h=$(grep -c '^LHS:' "$d/cmp.log"; true)
  echo "=== $m ${t%-*} rc=$rc lines=$n heads=$h"
  [ "${QUIET:-0}" = 1 ] || head -${HEADN:-12} "$d/cmp.log"
done
