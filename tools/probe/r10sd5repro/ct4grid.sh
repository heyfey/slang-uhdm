#!/usr/bin/env bash
# r10sd4 grid driver.  LHS is ALWAYS golden.  Scores each cell with ct4law's
# question in its sharpest form: for every typespec in the arm, print the
# vpiInstance state on BOTH sides, keyed by span, so the cell's verdict is read
# rather than eyeballed off a dump.
#   usage: SLANG_UHDM=<binary> ./ct4grid.sh <tag>
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:-x}
: "${SLANG_UHDM:?set SLANG_UHDM}"
KEYTOOL=${CT4KEY:-/tmp/r10sd4_ct4key}
for f in "$HERE"/grid/q*.sv; do
  b=$(basename "$f" .sv)
  D=/tmp/r10sd4_grid_${TAG}_$b
  out=$(SLANG_UHDM="$SLANG_UHDM" bash "$HERE/ct4arm.sh" "grid/$(basename "$f")" "$D" 2>&1)
  echo "=== $b"
  echo "$out" | grep -E "PASS_CMP|CMP_FAIL|DUMP_MATCH|DUMP_DIFF|SURELOG_FAIL|NO_OUTPUT|cmp heads"
  if [ -f "$D/slpp_all/surelog.uhdm" ] && [ -f "$D/slang.uhdm" ]; then
    "$KEYTOOL" "$D/slpp_all/surelog.uhdm" "$D/slang.uhdm" typespec 2>/dev/null |
      grep -E "^---|inst=|TOTAL"
  fi
done
