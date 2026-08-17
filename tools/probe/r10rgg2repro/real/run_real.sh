#!/usr/bin/env bash
# r10rgg2/real/run_real.sh — the REAL rggen_or_reducer.sv (Surelog's own
# third_party/tests/rggen copy) instantiated at controlled multiplicities,
# through real Surelog and both slang-uhdm binaries.  Prints the
# `list_index += 1` literal (line 30 col 22) per cell, per side.
#
#   usage: BASE=<binary> PAT=<binary> ./run_real.sh <outdir>
#
# The DUT is copied from Surelog's own tree at run time (never duplicated into
# this repo), so the cells can never drift from the file that carries the head.
#
# GUARD: a side with no dump prints UNMEASURED and is counted.
set -u
OUT=${1:?outdir}
here=$(cd "$(dirname "$0")" && pwd)
SL=~/git-repos/Surelog/build/bin/surelog
DUMP=~/git-repos/UHDM/build/bin/uhdm-dump
CELLS=$here/../cells.py
DUT=~/git-repos/Surelog/third_party/tests/rggen/rggen-sv-rtl/rggen_or_reducer.sv
[ -f "$DUT" ] || { echo "FATAL: no DUT at $DUT"; exit 3; }
bad=0
printf "%-7s %-34s %-34s %s\n" CELL GOLDEN BASE PATCHED
for d in "$here"/e*/; do
  c=$(basename "$d")
  w=$OUT/$c; mkdir -p "$w" || exit 1
  cp "$d"/*.sv "$DUT" "$w"/
  ( cd "$w" && "$SL" -parse -nopython -d uhdm -top top_$c rggen_or_reducer.sv top_$c.sv \
      > gold.dump 2> gold.err )
  g=$("$CELLS" "$w/gold.dump" 2>/dev/null | awk '$1=="30:22"{print $2}')
  [ -z "$g" ] && { g=UNMEASURED; bad=$((bad+1)); }
  o=()
  for b in "${BASE:?BASE=}" "${PAT:?PAT=}"; do
    ( cd "$w" && "$b" --single-unit --top top_$c rggen_or_reducer.sv top_$c.sv \
        -o ours.uhdm > ours.log 2>&1 )
    "$DUMP" "$w/ours.uhdm" > "$w/ours.dump" 2>&1
    v=$("$CELLS" "$w/ours.dump" 2>/dev/null | awk '$1=="30:22"{print $2}')
    [ -z "$v" ] && { v=UNMEASURED; bad=$((bad+1)); }
    o+=("$v")
  done
  printf "%-7s %-34s %-34s %s\n" "$c" "$g" "${o[0]}" "${o[1]}"
done
echo "UNMEASURED=$bad"
[ $bad -eq 0 ]
