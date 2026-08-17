#!/usr/bin/env bash
# r10rgg2/vsweep_run.sh — THE MEASUREMENT THAT REFUTES A COUNT MODEL.
#
# Six variants of the SAME rggen_or_reducer body, ONE instance, N in {20,25},
# differing only in which localparams / declarations CONSUME `SUB_N_LIST`.
# The `list_index += 1` literal reads a DIFFERENT power of two in each, so the
# number of times Surelog constant-evaluates the function is not a function of
# the source at all -- it is demand-driven parameter resolution.
#
#   usage: BASE=<binary> PAT=<binary> ./vsweep_run.sh <outdir>
set -u
OUT=${1:?outdir}
here=$(cd "$(dirname "$0")" && pwd)
SL=~/git-repos/Surelog/build/bin/surelog
DUMP=~/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT" || exit 1
( cd "$OUT" && python3 "$here/vsweep_gen.py" ) || exit 1
bad=0
printf "%-9s %-26s %-14s %s\n" CELL GOLDEN BASE PATCHED
for d in "$OUT"/v*_n*/; do
  c=$(basename "$d")
  ( cd "$d" && "$SL" -parse -nopython -d uhdm -top top orv.sv top.sv > gold.dump 2> gold.err )
  g=$("$here/cells.py" "$d/gold.dump" 2>/dev/null | awk '$1=="28:22"{print $2}')
  [ -z "$g" ] && { g=UNMEASURED; bad=$((bad+1)); }
  o=()
  for b in "${BASE:?BASE=}" "${PAT:?PAT=}"; do
    ( cd "$d" && "$b" --single-unit --top top orv.sv top.sv -o ours.uhdm > ours.log 2>&1 )
    "$DUMP" "$d/ours.uhdm" > "$d/ours.dump" 2>&1
    v=$("$here/cells.py" "$d/ours.dump" 2>/dev/null | awk '$1=="28:22"{print $2}')
    [ -z "$v" ] && { v=UNMEASURED; bad=$((bad+1)); }
    o+=("$v")
  done
  printf "%-9s %-26s %-14s %s\n" "$c" "$g" "${o[0]}" "${o[1]}"
done
echo "UNMEASURED=$bad"
[ $bad -eq 0 ]
