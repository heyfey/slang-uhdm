#!/usr/bin/env bash
# r10uvm194repro/predict194.sh — THE MOVER PREDICTION, from PRISTINE databases
# and their goldens ALONE.  MEASUREMENT ONLY.
#
#   predict194.sh <census dir made by cen194.sh on the PRISTINE workdir> [out]
#
# § homeRetNameSelBindSurvivesDefViewUnbind194 can only move a reference that
# is, in the pristine pair:
#   * a return-name reference (that is the census population), AND
#   * bound BY GOLDEN to a SELECT-family object (bit_select / part_select /
#     indexed_part_select / var_select), AND
#   * bound by US to NOTHING.
# Every other cell is outside the law by construction: the law only ever LEAVES
# a binding in place that `classRetNameDefViewNoBind37` would have nulled, so a
# cell where we already agree cannot move and a cell where we bind something
# else is not this law's (nothing here ever changes a non-null actual).
#
# The clone fence cannot be read off a database without the emitter's own
# `pkgImportCloneTfs16`, so this prints the clone-suspect cells SEPARATELY
# (their home chain names a package that is not the one declaring the routine)
# rather than silently folding them in.
set -u
D=${1:?census dir}; OUT=${2:-/dev/stdout}
{
  echo "# PREDICTED MOVER CELLS — golden binds a SELECT, we bind NOTHING"
  echo "# key: <subroutine>|<ref line:col>|<named ancestor chain>"
  tot=0
  for g in "$D"/*.g.txt; do
    [ -f "$g" ] || continue
    row=$(basename "$g" .g.txt)
    o=$D/$row.o.txt
    [ -f "$o" ] || continue
    # golden cells whose ACT is a SELECT, intersected with OUR cells that
    # carry no actual at all.  `comm` on whole sorted lines, never `join` — the
    # key itself contains `|`, and a field-splitting join manufactures a CROSS
    # PRODUCT (this script printed 4 "movers" for 2 real keys before the fix).
    gsel=$(mktemp); onone=$(mktemp)
    sed -n 's/^RET|g|\(.*\)|ACT=\(bit_select\|part_select\|indexed_part_select\|var_select\):.*/\1/p' "$g" | sort -u > "$gsel"
    sed -n 's/^RET|o|\(.*\)|ACT=NONE$/\1/p' "$o" | sort -u > "$onone"
    n=0
    while IFS= read -r k; do
      [ -n "$k" ] || continue
      echo "MOVER $row $k"
      n=$((n+1))
    done < <(comm -12 "$gsel" "$onone")
    rm -f "$gsel" "$onone"
    [ "$n" -gt 0 ] && echo "ROW $row keys=$n"
    tot=$((tot+n))
  done
  echo "TOTAL-KEYS $tot"
  echo "# (keys are DEDUPED per row; one key can carry several listing copies)"
} > "$OUT"
