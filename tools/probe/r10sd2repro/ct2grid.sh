#!/usr/bin/env bash
# r10sd2 GRID DRIVER — one row per arm, answering the brief's stated questions
# about the DESIGN's package vectors:
#   * which vector does a package land in (uhdmallPackages / uhdmtopPackages)?
#   * is membership driven by declaration, by import, by use, or by $unit?
#   * do WE agree with golden, cell for cell?
# Prints, for each arm: golden's and our AllPackages/TopPackages membership (by
# name, IN ORDER) and the arm's cmp head, so a divergence is visible per cell.
#
# GUARDS carried from ct2arm.sh: SLANG_UHDM has no default; missing inputs are
# fatal (uhdm-cmp exits 0 on a missing file); every arm runs in its own scratch
# dir because Surelog synthesises builtin.sv into the CWD.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
PKGV=${CT2PKGV:-/tmp/r10sd2_ct2pkgv}
[ -x "$PKGV" ] || { echo "NO_CT2PKGV at $PKGV"; exit 9; }
TAG=${1:-grid}
for f in "$HERE"/grid/p*.sv; do
  b=$(basename "$f" .sv)
  d=/tmp/r10sd2_${TAG}_$b
  out=$(bash "$HERE/ct2arm.sh" "grid/$b.sv" "$d" 2>&1)
  echo "=== $b"
  echo "$out" | sed 's/^/    /'
  if [ -f "$d/slpp_all/surelog.uhdm" ]; then
    "$PKGV" "$d/slpp_all/surelog.uhdm" G 2>/dev/null |
      grep -E "AllPackages\[|TopPackages\[|AllPackages size|TopPackages size" |
      sed -E 's/(name=[^ ]+).*/\1/' | sed 's/^/    /'
  fi
  if [ -f "$d/slang.uhdm" ]; then
    "$PKGV" "$d/slang.uhdm" O 2>/dev/null |
      grep -E "AllPackages\[|TopPackages\[|AllPackages size|TopPackages size" |
      sed -E 's/(name=[^ ]+).*/\1/' | sed 's/^/    /'
  fi
done
