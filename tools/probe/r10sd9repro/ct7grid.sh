#!/usr/bin/env bash
# r10sd7 GRID DRIVER.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: SLANG_UHDM=<binary> ./ct7grid.sh <tag>
#
# Each cell runs through ct7arm.sh (own scratch dir, `sed 1d` on both dumps,
# uhdm-cmp guarded against missing inputs) and is then SCORED on BOTH databases
# with TWO instruments, because this law needs both halves to be read:
#
#   ct7pop     — every typespec in the typespec subtree of every CLASS-listing
#                variable, with its DEPTH and its vpiInstance.  This is the cell
#                the patch moves.
#   ct7pkgsub  — the same subtree on the PACKAGE's OWN listing.  This is the cell
#                the patch must NOT move, and it is what makes the law belong to
#                the copy rather than to the array emitter.
#
# GUARD — THE EMPTY-PRODUCT HUNT: a cell whose ct7pop population is EMPTY on
# either side is printed as EMPTY-SCORE.  ct7pop exits 5 on an empty population
# and that exit is surfaced, never hidden: an "unchanged" verdict on a cell that
# scores nothing is agreement that costs nothing.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:-x}
: "${SLANG_UHDM:?set SLANG_UHDM}"
POP=${CT7POP:-/tmp/r10sd7_ct7pop}
PKG=${CT7PKGSUB:-/tmp/r10sd7_ct7pkgsub}
VAR=${CT7VAR:-m}
[ -x "$POP" ] || { echo "FATAL: no ct7pop at $POP"; exit 3; }
[ -x "$PKG" ] || { echo "FATAL: no ct7pkgsub at $PKG"; exit 3; }
for f in "$HERE"/grid7/g*.sv; do
  b=$(basename "$f" .sv)
  n=${b:1:1}                      # cell number -> the package variable is m<N>
  D=/tmp/r10sd7_grid_${TAG}_$b
  out=$(SLANG_UHDM="$SLANG_UHDM" bash "$HERE/ct7arm.sh" "grid7/$(basename "$f")" "$D" 2>&1)
  echo "=== $b"
  echo "$out" | grep -E "PASS_CMP|CMP_FAIL|DUMP_MATCH|DUMP_DIFF|SURELOG_FAIL|NO_OUTPUT|cmp heads"
  for side in "slpp_all/surelog.uhdm:GOLDEN" "slang.uhdm:OURS"; do
    p=${side%%:*}; lbl=${side##*:}
    if [ ! -f "$D/$p" ]; then echo "  $lbl NO-DATABASE"; continue; fi
    o=$("$POP" "$D/$p" 2>&1); rc=$?
    nn=$(printf '%s\n' "$o" | grep -c ' | d[0-9] ' || true)
    if [ "$rc" = 5 ] || [ "$nn" = 0 ]; then
      echo "  $lbl CLASS EMPTY-SCORE (rc=$rc)"
    else
      printf '%s\n' "$o" | grep ' | d[0-9] ' | sed "s/^/  $lbl CLS /"
    fi
    k=$("$PKG" "$D/$p" "m$n" 2>&1); krc=$?
    if [ "$krc" = 5 ]; then
      echo "  $lbl PKG  no-package-listing-for-m$n"
    else
      printf '%s\n' "$k" | grep -E '^==|index|elem' | sed "s/^/  $lbl PKG /"
    fi
  done
done
