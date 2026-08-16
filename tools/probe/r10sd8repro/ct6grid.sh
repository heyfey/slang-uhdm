#!/usr/bin/env bash
# r10sd6 GRID DRIVER.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: SLANG_UHDM=<binary> ./ct6grid.sh <tag>
#
# Each cell is run through ct6arm.sh (its own scratch dir, `sed 1d` on both
# dumps, uhdm-cmp guarded against missing inputs), and then SCORED with ct6clsref
# on BOTH databases — the scored cell is the CLASS listing copy's initialiser
# reference: its vpiFullName and its vpiActual.  Scoring is READ, never eyeballed
# off a dump.
#
# GUARD — THE EMPTY-PRODUCT HUNT: a cell whose ct6clsref population is EMPTY on
# either side is printed as `EMPTY-SCORE`, because an "unchanged" verdict on a
# cell that scores nothing is agreement that costs nothing.  ct6clsref itself
# exits 5 on an empty population; that exit is surfaced here rather than hidden.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:-x}
: "${SLANG_UHDM:?set SLANG_UHDM}"
SCORE=${CT6CLSREF:-/tmp/r10sd6_ct6clsref}
[ -x "$SCORE" ] || { echo "FATAL: no ct6clsref at $SCORE"; exit 3; }
for f in "$HERE"/grid6/g*.sv; do
  b=$(basename "$f" .sv)
  D=/tmp/r10sd6_grid_${TAG}_$b
  out=$(SLANG_UHDM="$SLANG_UHDM" bash "$HERE/ct6arm.sh" "grid6/$(basename "$f")" "$D" 2>&1)
  echo "=== $b"
  echo "$out" | grep -E "PASS_CMP|CMP_FAIL|DUMP_MATCH|DUMP_DIFF|SURELOG_FAIL|NO_OUTPUT|cmp heads"
  for side in "slpp_all/surelog.uhdm:GOLDEN" "slang.uhdm:OURS"; do
    p=${side%%:*}; lbl=${side##*:}
    if [ ! -f "$D/$p" ]; then echo "  $lbl NO-DATABASE"; continue; fi
    o=$("$SCORE" "$D/$p" 2>&1); rc=$?
    n=$(printf '%s\n' "$o" | grep -c '^REF' || true)
    if [ "$rc" = 5 ] || [ "$n" = 0 ]; then
      echo "  $lbl EMPTY-SCORE (rc=$rc) $(printf '%s\n' "$o" | tail -2 | tr '\n' ' ')"
      continue
    fi
    printf '%s\n' "$o" | grep '^REF' | sed "s/^REF/  $lbl/"
    printf '%s\n' "$o" | tail -1 | sed "s/^/  $lbl /"
  done
done
