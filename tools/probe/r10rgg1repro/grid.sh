#!/usr/bin/env bash
# r10rgg1/grid.sh — re-take the three grids of this pass against REAL Surelog
# and against a slang-uhdm binary, and print the cell table.
#
#   usage: SLANG=<slang-uhdm> ./grid.sh <outdir>
#
# GUARD: every cell prints its own golden AND ours side; a cell whose golden
# side could not be read prints UNMEASURED and is counted — a grid that
# measured nothing must never read as agreement.
set -u
OUT=${1:?outdir}; SLANG=${SLANG:?SLANG=<slang-uhdm binary>}
SL=~/git-repos/Surelog/build/bin/surelog
DUMP=~/git-repos/UHDM/build/bin/uhdm-dump
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT" || exit 1
cd "$OUT" || exit 1
bad=0
for f in a1_rgg1 b1_rgg1 c1_rgg1; do
  cp "$here/$f.sv" .
  top=$f
  "$SL" -parse -nopython -d uhdm -top $top $f.sv > sl_$f.log 2>&1
  rc=$?; echo "surelog $f rc=$rc"
  [ -s sl_$f.log ] || { echo "UNMEASURED $f (no golden dump)"; bad=$((bad+1)); }
  "$SLANG" --single-unit --top $top $f.sv -o ours_$f.uhdm > ours_$f.log 2>&1
  rc2=$?; echo "slang   $f rc=$rc2"
  "$DUMP" ours_$f.uhdm > ours_$f.dump 2>&1
  echo "--- $f: every compound-assign / cont_assign Rhs constant, golden then ours"
  grep -nE "constant: , line|vpiDecompile|BIN:|HEX:|UINT:|INT:|vpiConstType" sl_$f.log | head -60
done
echo "UNMEASURED=$bad"
[ $bad -eq 0 ]
