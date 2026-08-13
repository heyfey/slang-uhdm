#!/usr/bin/env bash
# r10svs12 grid reader driver — run one arm and print its module_array /
# ref_module PORT cell table.
#
#   usage: SLANG_UHDM=<binary> TAG=<pris|ship> ./gridread.sh <arm.sv> <objpat>...
#
# The arm driver (svs12arm.sh) guards every ops trap this campaign has paid for
# (SLANG_UHDM never defaulted, `sed 1d` on both dumps, uhdm-cmp's
# exit-0-on-missing-input, a per-arm scratch dir because Surelog synthesizes
# builtin.sv in the CWD).  This wrapper adds only the CELL READ, which is
# portread.py walking the dump's INDENT COLUMN rather than grepping: a port is
# reprinted inside its own children as a vpiParent back-pointer, so a grep over
# the subtree over-counts.
#
# TAG keeps the pristine and shipped workdirs apart so both columns of the grid
# survive on disk and can be re-read without re-running.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=${1:?arm source}; shift
B=$(basename "$SRC"); B=${B%.*}
TAG=${TAG:?set TAG to pris or ship}
D=/tmp/r10svs12_arm_${TAG}_$B
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
"$HERE/svs12arm.sh" "$SRC" "$D" || exit $?
for OBJ in "$@"; do
    python3 "$HERE/portread.py" "$D/g.dump" "$D/o.dump" --obj "$OBJ"
done
echo "WD=$D"
