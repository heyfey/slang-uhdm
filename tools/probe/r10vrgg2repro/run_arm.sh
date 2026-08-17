#!/usr/bin/env bash
# r10vrgg2/run_arm.sh — one cell, four columns: GOLDEN (real Surelog), and each
# slang-uhdm binary handed in.  The cell's position comes from pos.py.
#
#   usage: BASE=<binary> PAT=<binary> [FIX=<binary>] ./run_arm.sh <celldir> ...
#
# GUARD: a side that produced no constant at the cell prints UNMEASURED and is
# COUNTED, so a run that measured nothing can never read as agreement.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
here=$(cd "$(dirname "$0")" && pwd)
CELLS=$here/../r10rgg2repro/cells.py
BASE=${BASE:?BASE=<base binary>}; PAT=${PAT:?PAT=<patched binary>}
bad=0
hdr=$(printf "%-20s %-7s %-26s %-26s %-26s" CELL POS GOLDEN BASE PATCHED)
[ -n "${FIX:-}" ] && hdr="$hdr$(printf ' %-26s' VERIFIED)"
echo "$hdr"
for d in "$@"; do
  c=$(basename "$d"); P=$(python3 "$here/pos.py" "$d/dut.sv")
  ( cd "$d" && "$SL" -parse -nopython -d uhdm -top top dut.sv top.sv > gold.dump 2> gold.err )
  g=$("$CELLS" "$d/gold.dump" 2>/dev/null | awk -v p="$P" '$1==p{print $2; exit}')
  [ -z "$g" ] && { g=UNMEASURED; bad=$((bad+1)); }
  row=$(printf "%-20s %-7s %-26s" "$c" "$P" "$g")
  for b in "$BASE" "$PAT" ${FIX:-}; do
    ( cd "$d" && "$b" --single-unit --top top dut.sv top.sv -o ours.uhdm > ours.log 2>&1 )
    "$DUMP" "$d/ours.uhdm" > "$d/ours.dump" 2>&1
    v=$("$CELLS" "$d/ours.dump" 2>/dev/null | awk -v p="$P" '$1==p{print $2; exit}')
    [ -z "$v" ] && { v=UNMEASURED; bad=$((bad+1)); }
    row="$row$(printf ' %-26s' "$v")"
  done
  echo "$row"
done
echo "UNMEASURED=$bad"
[ $bad -eq 0 ]
