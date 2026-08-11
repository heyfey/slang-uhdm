#!/bin/bash
# r10uvm53repro/cells.sh — print the arm-cell table for one arm, BOTH SIDES,
# from a gold.sh outdir.  Cell names are the `cN_`/`dN_`/`eN_` variable names
# written in the arm's dut.sv.
#
# LHS is ALWAYS golden(Surelog) = g.dump; RHS is ALWAYS ours = o.dump.
#
# GUARD: both dumps are existence-checked; a missing one is a hard exit, never
# an empty (green-looking) table.  ctsprobe.py itself refuses to report on a
# dump with zero class_typespec objects and counts UNMEASURED rows.
set -u
OUT=${1:?gold.sh outdir}
PAT=${2:-'c[0-9]_|d[0-9]_|e[0-9]_|m_cfg_dap'}
HERE=$(cd "$(dirname "$0")" && pwd)
for f in "$OUT/g.dump" "$OUT/o.dump"; do
  [ -s "$f" ] || { echo "FATAL: missing or empty $f"; exit 3; }
done
echo "######## LHS golden(Surelog): $OUT/g.dump"
python3 "$HERE/ctsprobe.py" cell "$OUT/g.dump" "$PAT" || exit 4
echo "######## RHS ours: $OUT/o.dump"
python3 "$HERE/ctsprobe.py" cell "$OUT/o.dump" "$PAT" || exit 4
