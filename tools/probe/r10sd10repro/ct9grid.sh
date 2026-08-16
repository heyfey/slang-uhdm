#!/usr/bin/env bash
# r10sd9 grid driver.  Runs every grid9 cell on BOTH binaries and scores each
# one on THREE measures, not one:
#   * the whole-design uhdm-cmp verdict (PASS_CMP / CMP_FAIL) + head count,
#   * the DUMP CONTENT count (`diff -u` +/- lines, header excluded),
#   * ct9id — the ELEMENT-TYPESPEC IDENTITY census, golden vs ours, row by row.
# The third is the one that decides: a cell can be CMP_FAIL on both binaries for
# an unrelated reason (v1's `logic_var`/`ref_var` element-variable KIND head) and
# still be the cell that proves or refutes the law.
#
#   usage: PRIS=<pristine binary> PATCHED=<patched binary> ./ct9grid.sh [cell...]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?set PRIS to the pristine binary}
PATCHED=${PATCHED:?set PATCHED to the patched binary}
ID=${CT9ID:-/tmp/r10sd9_id}
[ -x "$ID" ] || { echo "FATAL: no ct9id at $ID (build it first)"; exit 3; }
CELLS=${*:-}
if [ -z "$CELLS" ]; then
  CELLS=$(cd "$HERE/grid9" && ls *.sv)
fi
for c in $CELLS; do
  b=${c%.sv}
  echo "======== $b"
  for arm in pris patched; do
    if [ "$arm" = pris ]; then BIN=$PRIS; else BIN=$PATCHED; fi
    D=/tmp/r10sd9_grid_${arm}_$b
    out=$(SLANG_UHDM="$BIN" "$HERE/ct8arm.sh" "grid9/$c" "$D" 2>&1)
    verdict=$(echo "$out" | grep -E '^(PASS_CMP|CMP_FAIL|SURELOG_FAIL|NO_OUTPUT)')
    heads=$(echo "$out" | grep '^cmp heads=')
    content=$(echo "$out" | grep -E '^(DUMP_MATCH|DUMP_DIFF)')
    echo "  [$arm] $verdict | $heads | $content"
    if [ -f "$D/slpp_all/surelog.uhdm" ] && [ -f "$D/slang.uhdm" ]; then
      "$ID" "$D/slpp_all/surelog.uhdm" "$D/slang.uhdm" --all > "$D/id.txt" 2>&1
      grep '^\[S\]' "$D/id.txt" | sed "s/^/  [$arm] /"
    fi
  done
  # The row-level delta between the two arms is the cell's verdict on the law.
  if [ -f /tmp/r10sd9_grid_pris_$b/id.txt ] && [ -f /tmp/r10sd9_grid_patched_$b/id.txt ]; then
    if diff -q /tmp/r10sd9_grid_pris_$b/id.txt /tmp/r10sd9_grid_patched_$b/id.txt >/dev/null; then
      echo "  ID_CENSUS: IDENTICAL between the two binaries"
    else
      echo "  ID_CENSUS: MOVED --"
      diff -u /tmp/r10sd9_grid_pris_$b/id.txt /tmp/r10sd9_grid_patched_$b/id.txt |
        grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' | sed 's/^/    /'
    fi
  fi
done
