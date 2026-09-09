#!/bin/bash
# r11u3 head census: for each named test in a verify_golden workdir mode dir,
# run the official uhdm-cmp (golden LHS, ours RHS) and print a one-line head digest.
# usage: heads.sh <workdir/mode> <outdir> <names...>
WD=$1; shift
OUT=$1; shift
mkdir -p "$OUT"
CMP=${CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
for n in "$@"; do
  d=$(ls -d "$WD"/$n-* 2>/dev/null | head -1)
  if [ -z "$d" ]; then echo "$n SKIP-NODIR"; continue; fi
  g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' "$d/cmds.txt")
  if [ -z "$g" ]; then g=$(sed -n 's/^surelog: *//p' "$d/cmds.txt" | grep -o '[^ ]*surelog.uhdm' | head -1); gu=$g; else gu=$g/golden.uhdm; fi
  if [ ! -f "$gu" ]; then echo "$n SKIP-NOGOLDEN"; continue; fi
  if [ ! -f "$d/slang.uhdm" ]; then echo "$n SKIP-NOOURS"; continue; fi
  "$CMP" "$gu" "$d/slang.uhdm" > "$OUT/$n.cmp" 2>&1
  rc=$?
  hd=$(grep -c '^LHS:' "$OUT/$n.cmp")
  ln=$(wc -l < "$OUT/$n.cmp")
  first=$(sed -n '2,3p' "$OUT/$n.cmp" | tr '\n' ' ')
  echo "$n rc=$rc heads=$hd lines=$ln | $first"
done
