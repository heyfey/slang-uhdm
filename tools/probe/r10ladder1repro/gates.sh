#!/bin/bash
# r10ladder1/gates.sh — run every gate of this pass and print the evidence.
#
#   usage: gates.sh <workdir> <outdir> [<mode:name> ...]      (defaults: the 11 NE rows)
#
# GATE 1 build        — the build line, against the OFFICIAL UHDM install
# GATE 2 calibration  — golden-vs-golden gives ZERO rungs (>=3 rows)
# GATE 3 sanity       — rung #1 is BYTE-IDENTICAL to uhdm-cmp's head, per row
# GATE 4 determinism  — two runs of a row give the same ladder
#
# GUARD: each gate's exit status is captured and echoed; a gate that could not
# run at all is a FAILURE, never a skip.  The final line is the only place a
# verdict is printed, and it is computed from the four statuses, not asserted.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
ROWS=("$@")
if [ ${#ROWS[@]} -eq 0 ]; then
  ROWS=(default:SeqDriver default:SimpleUVM default:Scoreboard default:BuildUVMPkg
        default:Earlgrey_0_1 testflags:SeqDriver testflags:SimpleUVM
        testflags:BuildUVMPkg default:YosysVerx testflags:YosysVerx default:Rggen)
fi
here=$(dirname "$0")
mkdir -p "$OUT" || exit 1
echo "=== GATE 1: build against the official UHDM install"
g++ -O2 -std=c++17 "$here/ctladder.cpp" -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o "$OUT/ctladder"
g1=$?; echo "build rc=$g1"; export CTLADDER=$OUT/ctladder
echo; echo "=== GATE 2: calibration (golden vs golden must give ZERO rungs)"
"$here/calib.sh" "$WD" "${ROWS[@]}"; g2=$?
echo; echo "=== GATE 3: sanity (rung #1 == uhdm-cmp head, byte for byte)"
"$here/rowsanity.sh" "$WD" "$OUT" "${ROWS[@]}"; g3=$?
echo; echo "=== GATE 4: determinism (two runs, identical ladders)"
"$here/detcheck.sh" "$WD" "$OUT" "${ROWS[@]}"; g4=$?
echo
echo "[S] GATES build=$g1 calib=$g2 sanity=$g3 determinism=$g4"
[ $g1 -eq 0 ] && [ $g2 -eq 0 ] && [ $g3 -eq 0 ] && [ $g4 -eq 0 ] && echo "[S] ALL GATES PASS" || echo "[S] GATE FAILURE"
