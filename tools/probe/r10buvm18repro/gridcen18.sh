#!/usr/bin/env bash
# r10buvm18repro/gridcen18.sh — THE GOLDEN GRID.  MEASUREMENT ONLY.
#
# Runs Surelog on `grid18.sv` (declared type x home x initializer x
# parameter/localparam x DEF/ELAB, all in one source) and prints the
# parameter-typespec census of the resulting GOLDEN database.  This is the
# measurement § pkgParamBareTdNamedClone18 was decoded from; re-run it before
# widening the arm to any shape it does not already cover.
set -u
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-/tmp/r10buvm18_grid}
CEN=${CEN:-/tmp/r10buvm18_cen}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
[ -x "$CEN" ] || bash "$D/build18.sh" "$CEN" >/dev/null
rm -rf "$OUT"; mkdir -p "$OUT"
cp "$D/grid18.sv" "$OUT/grid.sv"
( cd "$OUT" && "$SURELOG" -parse -sv -nobuiltin -nocache -mt 0 -mp 0 -o "$OUT/w" grid.sv >sl.log 2>&1 ) </dev/null
echo "surelog rc=$? errors=$(grep -c '^\[  ERROR\] : [1-9]' "$OUT/sl.log" 2>/dev/null || true)"
"$CEN" "$OUT/w/slpp_all/surelog.uhdm"
