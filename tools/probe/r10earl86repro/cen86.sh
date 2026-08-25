#!/usr/bin/env bash
# r10earl86 — THE CORPUS CENSUS DRIVER.  For every database in a sweep workdir,
# read OUR .uhdm and the GOLDEN one named by that test's OWN cmds.txt (the
# immutable golden-cache path) with `pacen86`, join the rows on the KEY and
# classify every ELAB `param_assign` cell.  READS databases and DISPATCHES
# NOTHING, so no test -- fenced or otherwise -- is run by it.  MEASUREMENT ONLY.
#   usage: cen85.sh <sweep-workdir> <out-prefix>
#   env:   PACEN86
set -u
CEN=${PACEN86:?set PACEN86}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
WD=$(readlink -f "$1"); OUT=$2
: > $OUT.cells; : > $OUT.dbs; : > $OUT.skipped
n=0
while read -r db; do
  d=$(dirname "$db")
  g=$(grep -o '/home/[^ )]*/golden.uhdm' "$d/cmds.txt" 2>/dev/null | head -1)
  if [ -z "$g" ]; then
    c=$(grep -o 'golden cache hit [^ )]*' "$d/cmds.txt" 2>/dev/null | awk '{print $4}')
    [ -n "$c" ] && g="$c/golden.uhdm"
  fi
  [ -n "$g" ] && [ -f "$g" ] || { echo "NOGOLDEN ${d#$WD/}" >> $OUT.skipped; continue; }
  n=$((n+1))
  rel=${d#$WD/}
  "$CEN" "$g"  --inst 2>/dev/null | sed "s#^#G\t$rel\t#" >> $OUT.cells
  "$CEN" "$db" --inst 2>/dev/null | sed "s#^#O\t$rel\t#" >> $OUT.cells
  echo "$rel" >> $OUT.dbs
done < <(find "$WD" -name 'slang.uhdm' | sort)
echo "DATABASES_READ=$n SKIPPED=$(wc -l < $OUT.skipped)"
