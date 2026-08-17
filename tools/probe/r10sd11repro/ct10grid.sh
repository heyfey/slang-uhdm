#!/usr/bin/env bash
# r10sd10 grid driver.  Runs every grid10 cell on BOTH binaries and scores each
# one on THREE measures, not one:
#   * the whole-design uhdm-cmp verdict (PASS_CMP / CMP_FAIL) + head count,
#   * the DUMP CONTENT count (`diff -u` +/- lines, header excluded),
#   * THE VARIABLE-KIND TABLE, golden vs ours, row by row — which is the one
#     that decides here, because a cell can stay CMP_FAIL on both binaries for
#     an unrelated reason and still be the cell that proves or refutes the law.
#
# The kind table is `<uhdm class> <fullname>` for every variable the cell's two
# dumps name, so a cell with ZERO differing rows is reported as EXACT and a
# cell whose rows only MOVE is reported with the moved rows printed, never
# summarised.
#
#   usage: PRIS=<pristine binary> PATCHED=<patched binary> ./ct10grid.sh [cell...]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?set PRIS to the pristine binary}
PATCHED=${PATCHED:?set PATCHED to the patched binary}
CELLS=${*:-}
if [ -z "$CELLS" ]; then
  CELLS=$(cd "$HERE/grid10" && ls *.sv)
fi
kindtab() {   # <dump>  -> "class  fullname" for every variable, sorted unique
  grep -oE '\\_[a-z_]*_var: \([^)]*\), line:[0-9]+:[0-9]+' "$1" |
    sed -E 's/^\\_//; s/: \(/ /; s/\), line:/ @/' | LC_ALL=C sort -u
}
for c in $CELLS; do
  b=${c%.sv}
  echo "======== $b"
  for arm in pris patched; do
    if [ "$arm" = pris ]; then BIN=$PRIS; else BIN=$PATCHED; fi
    D=/tmp/r10sd10_grid_${arm}_$b
    out=$(SLANG_UHDM="$BIN" "$HERE/ct8arm.sh" "grid10/$c" "$D" 2>&1)
    verdict=$(echo "$out" | grep -E '^(PASS_CMP|CMP_FAIL|SURELOG_FAIL|NO_OUTPUT)')
    heads=$(echo "$out" | grep '^cmp heads=')
    content=$(echo "$out" | grep -E '^(DUMP_MATCH|DUMP_DIFF)')
    echo "  [$arm] $verdict | $heads | $content"
    if [ -f "$D/g.dump" ] && [ -f "$D/o.dump" ]; then
      kindtab "$D/g.dump" > "$D/g.kinds"
      kindtab "$D/o.dump" > "$D/o.kinds"
      n=$(comm -3 "$D/g.kinds" "$D/o.kinds" | wc -l)
      gv=$(wc -l < "$D/g.kinds")
      echo "  [$arm] KINDS golden_rows=$gv differing_sides=$n"
      [ "$gv" -gt 0 ] || echo "  [$arm] REFUSING TO REPORT: the cell names no variable"
      comm -3 "$D/g.kinds" "$D/o.kinds" | sed "s/^/    [$arm] /"
    fi
  done
  if [ -f /tmp/r10sd10_grid_pris_$b/o.kinds ] &&
     [ -f /tmp/r10sd10_grid_patched_$b/o.kinds ]; then
    if diff -q /tmp/r10sd10_grid_pris_$b/o.kinds \
               /tmp/r10sd10_grid_patched_$b/o.kinds > /dev/null; then
      echo "  KINDS: IDENTICAL between the two binaries"
    else
      echo "  KINDS: MOVED --"
      diff -u /tmp/r10sd10_grid_pris_$b/o.kinds \
              /tmp/r10sd10_grid_patched_$b/o.kinds |
        grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' | sed 's/^/    /'
    fi
  fi
done
