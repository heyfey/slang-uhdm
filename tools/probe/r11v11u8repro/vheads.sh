#!/bin/bash
# r11v11u8 - per-row head: cmp lines + head count + the head's LHS/RHS lines.
# usage: vheads.sh <workdir/mode> <outdir> [rowglob...]
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
D=${1:?workdir/mode}; O=${2:?outdir}; shift 2
mkdir -p "$O"
for g in "$@"; do
  for d in "$D"/$g*; do
    [ -d "$d" ] || continue
    n=$(basename "$d")
    gold=$(grep -oE '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]+' "$d/cmds.txt" | head -1)
    [ -n "$gold" ] || { echo "$n NOGOLD"; continue; }
    [ -f "$gold/golden.uhdm" ] || { echo "$n NOGOLDFILE $gold"; continue; }
    $CMP "$gold/golden.uhdm" "$d/slang.uhdm" > "$O/$n.out" 2> "$O/$n.err"
    rc=$?
    echo "$n rc=$rc lines=$(wc -l < "$O/$n.out") heads=$(grep -c '^LHS:' "$O/$n.err"; true) | $(head -2 "$O/$n.err" | tr '\n' '~' | cut -c1-200)"
  done
done
exit 0
