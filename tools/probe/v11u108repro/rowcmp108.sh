#!/bin/bash
# rowcmp108.sh <sweep-root> <out-dir> name... : official uhdm-cmp (LHS golden) per row, both modes.
# Golden = the cache path its cmds.txt names; ours = slang.uhdm; prints name mode lines heads binary.
R=${1:?}; O=${2:?}; shift 2; mkdir -p "$O"
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
for n in "$@"; do for m in default testflags; do
  d=$(ls -d "$R"/*/"$m"/"$n"-* 2>/dev/null | head -1)
  [ -z "$d" ] && { echo "$n $m NODIR"; continue; }
  g=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$d/cmds.txt")/golden.uhdm
  b=$(sed -n 's/^slang: *\([^ ]*\).*/\1/p' "$d/cmds.txt")
  "$CMP" "$g" "$d/slang.uhdm" > "$O/$n.$m.cmp" 2>&1; rc=$?
  echo "$n $m lines=$(wc -l < "$O/$n.$m.cmp") heads=$(grep -c '^LHS:' "$O/$n.$m.cmp"; true) rc=$rc bin=$b"
done; done
