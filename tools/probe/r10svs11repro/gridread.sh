#!/usr/bin/env bash
# r10svs11 grid reader driver — run one arm and print its Nets() cell table.
#
#   usage: SLANG_UHDM=<binary> ./gridread.sh <arm.sv>
#
# The arm driver (svs11arm.sh) already guards every ops trap this campaign has
# paid for (SLANG_UHDM never defaulted, `sed 1d` on both dumps, uhdm-cmp's
# exit-0-on-missing-input, per-arm scratch dir for Surelog's builtin.sv).  This
# wrapper adds only the CELL READ, which is `netread.py` walking the dump's
# INDENT COLUMN rather than grepping: the nets being measured are reprinted
# inside other objects as vpiParent back-pointers and as ref_obj actuals, so a
# grep over the subtree over-counts.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/r10svs11_arm_$B
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
"$HERE/svs11arm.sh" "$SRC" "$D" || exit $?
echo "---- ${B}: work@top Nets(), LHS golden / RHS ours ----"
python3 "$HERE/netread.py" "$D/g.dump" "$D/o.dump" \
        --obj 'module_inst: work@top ' --field vpiNet
