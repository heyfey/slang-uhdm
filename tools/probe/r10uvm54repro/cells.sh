#!/bin/bash
# r10uvm54repro/cells.sh — the ARM CELL TABLE for one gold.sh outdir: BOTH
# SIDES of every class-nested class-handle typedef cell, plus the group/base
# view.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#
#   usage: cells.sh <gold.sh-outdir> [row-name-regex]
#
# GUARDS (each an ops trap this campaign has paid for):
#   * both dumps are existence- AND size-checked; a missing dump is a hard
#     exit 6 and never a verdict (uhdm-cmp exits 0 on a missing input, and a
#     driver that reaches nothing must not read as clean).
#   * tdgroup.py itself exits 4 with `UNMEASURED:` when it reaches no
#     class_defn-owned class_typespec, and prints UNMEASURED for any field it
#     cannot resolve; those exits are propagated, not swallowed.
#   * gold.sh already strips the dump's FIRST LINE (the DATABASE PATH); this
#     script only reads the stripped dumps it produced.
set -u
OUT=${1:?gold.sh outdir}
PAT=${2:-}
HERE=$(cd "$(dirname "$0")" && pwd)
G=$OUT/g.dump
O=$OUT/o.dump
for f in "$G" "$O"; do
  [ -f "$f" ] || { echo "NO_OUTPUT: $f absent"; exit 6; }
  [ -s "$f" ] || { echo "NO_OUTPUT: $f empty"; exit 6; }
done
echo "OUT=$OUT  g.dump=$(wc -l < "$G") lines  o.dump=$(wc -l < "$O") lines"
python3 "$HERE/tdgroup.py" "$G" rows "$PAT" > "$OUT/g.rows" || exit $?
python3 "$HERE/tdgroup.py" "$O" rows "$PAT" > "$OUT/o.rows" || exit $?
echo "---- CELLS (join: LHS golden vs RHS ours; only non-EQ unless --all)"
python3 "$HERE/join.py" "$OUT/g.rows" "$OUT/o.rows" || exit $?
echo "---- GROUPS, LHS golden"
python3 "$HERE/tdgroup.py" "$G" groups "$PAT" || exit $?
echo "---- GROUPS, RHS ours"
python3 "$HERE/tdgroup.py" "$O" groups "$PAT" || exit $?
