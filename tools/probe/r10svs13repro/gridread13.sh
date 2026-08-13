#!/usr/bin/env bash
# r10svs13 grid reader — run every arm on ONE binary and print all 31 cells.
#
#   usage: SLANG_UHDM=<binary> TAG=<pris|ship> ./gridread13.sh
#
# The arm driver (svs13arm.sh) guards every ops trap this campaign has paid for
# (SLANG_UHDM never defaulted, `sed 1d` on BOTH dumps, uhdm-cmp's
# exit-0-on-missing-input, a per-arm scratch dir because Surelog synthesizes
# builtin.sv in the CWD).  This wrapper adds only the CELL READ, which is
# iaread.py walking the dump's INDENT COLUMN rather than grepping.
#
# TAG keeps the pristine and shipped workdirs apart so both columns of the grid
# survive on disk and can be re-read without re-running.
#
# Cells are keyed by the instance's ELAB FULLNAME — `(work@top.p1)` — which can
# never collide with its DEF view `(work@leaf2p)`.  The design-wide `--census`
# line is printed per arm because a cell table alone cannot say whether a wrapper
# we stopped OWNING still EXISTS: the census counts `|vpiInterfaceArray:` labels
# AND `\_interface_array:` own listings separately, so an object that merely lost
# its owner is distinguishable from one that vanished.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${TAG:?set TAG to pris or ship}
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
run() { # run <arm> <cell-fullnames...>
    local A=$1; shift
    local D=/tmp/r10svs13_arm_${TAG}_${A%%_*}
    echo "===== $A (TAG=$TAG)"
    "$HERE/svs13arm.sh" "$A.sv" "$D" | tail -4
    local args=(--census)
    for c in "$@"; do args+=(--obj "(work@top.$c)"); done
    python3 "$HERE/iaread.py" "$D/g.dump" "$D/o.dump" "${args[@]}" || true
}
run a1_ifarrport   p1 p2 p3 p4 m1 m2 m3 m4
run a2_scalariface q1 q2 q3 q4 n1 n2 n3 n4
run a3_udpboundary s1p s1m s2p s2m s3p s3m s4p s4m s5p s5m s6p s6m
run a4_parentkinds h1 d1 d1.inner
