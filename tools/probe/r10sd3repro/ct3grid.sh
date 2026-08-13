#!/usr/bin/env bash
# r10sd3 GRID DRIVER — one row per arm, scoring § instanceIsNeverAClassDefn2
# cell for cell:
#   * does GOLDEN ever put a class_defn in a vpiInstance slot?  (the law)
#   * what does golden put in the slots the UVM shape makes us fill —
#     NULL, or the class's HOME package?  (the fix DIRECTION)
#   * which VIEW of the package (ALL: def / TOP: elaborated)?
#   * do WE agree, cell for cell?
#
# It calls ct3arm.sh for the emission (both sides, per-arm scratch dir) and then
# ct3cls on the two databases, printing section [A] (the whole-database state
# totals) and section [B] (the per-key verdict) for each cell.
#
# GUARDS carried from ct2arm.sh: SLANG_UHDM has no default (verify_golden.py and
# check_goldens.sh both silently default it to the MAIN-TREE binary); missing
# inputs are fatal (uhdm-cmp exits 0 on a missing file); every arm runs in its
# own scratch dir because Surelog synthesises builtin.sv into the CWD.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
CLS=${CT3CLS:-/tmp/r10sd3_ct3cls}
[ -x "$CLS" ] || { echo "NO_CT3CLS at $CLS"; exit 9; }
TAG=${1:-grid}
for f in "$HERE"/grid/g*.sv; do
  b=$(basename "$f" .sv)
  d=/tmp/r10sd3_${TAG}_$b
  out=$(bash "$HERE/ct3arm.sh" "grid/$b.sv" "$d" 2>&1)
  echo "=== $b"
  echo "$out" | sed 's/^/    /'
  if [ -f "$d/slpp_all/surelog.uhdm" ] && [ -f "$d/slang.uhdm" ]; then
    "$CLS" "$d/slpp_all/surelog.uhdm" "$d/slang.uhdm" 6 2>&1 |
      sed -n '/^\[A\]/,$p' | sed 's/^/    /'
  else
    echo "    NO_CENSUS (missing one side — arm did not produce both databases)"
  fi
done
