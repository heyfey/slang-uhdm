#!/bin/bash
# r11u10 — the unpacked-struct-array pattern grid.
# Usage: grid10.sh <slang-uhdm binary> [arm...]
# Every arm records surelog rc, our rc, cmp rc, cmp lines, head count, and
# the per-listing SHAPE of the parameter's param_assign Rhs on BOTH sides.
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
SHAPE=$(dirname "$0")/shape10.py
BIN=${1:?slang-uhdm binary}
shift
ROOT=${GRID_ROOT:-/tmp/r11u10_grid}
PARAM=${GRID_PARAM:-P}
ARMS=${*:-$(cd "$ROOT" && ls -d h* 2>/dev/null)}
for a in $ARMS; do
  d="$ROOT/$a"
  [ -f "$d/dut.sv" ] || { echo "=== $a NO-ARM"; continue; }
  (cd "$d" && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1); slrc=$?
  (cd "$d" && "$BIN" dut.sv --single-unit --nobuiltin -o ours.uhdm > ours.log 2>&1); ourc=$?
  $CMP "$d/slpp_all/surelog.uhdm" "$d/ours.uhdm" > "$d/cmp.out" 2> "$d/cmp.err"; cmprc=$?
  $DUMP "$d/slpp_all/surelog.uhdm" > "$d/gold.dump" 2>/dev/null
  $DUMP "$d/ours.uhdm" > "$d/ours.dump" 2>/dev/null
  echo "=== $a surelog_rc=$slrc ours_rc=$ourc cmp_rc=$cmprc cmplines=$(wc -l < "$d/cmp.out") heads=$(grep -c '^LHS:' "$d/cmp.err"; true)"
  SHAPE_DEPTH=${SHAPE_DEPTH:-2} python3 "$SHAPE" "$d/gold.dump" "$PARAM" | sed 's/^/  GOLD /'
  SHAPE_DEPTH=${SHAPE_DEPTH:-2} python3 "$SHAPE" "$d/ours.dump" "$PARAM" | sed 's/^/  OURS /'
done
exit 0
