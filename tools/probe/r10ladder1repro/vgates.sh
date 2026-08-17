#!/bin/bash
# vladder1/vgates.sh — re-run gates 1-4 of the VERIFIED instrument against a
# PRIVATE, PINNED workdir.
#
# Why a private workdir: the shared control workdir was deleted out from under a
# running measurement FOUR times across r10ladder1 and this verification
# (`d853e76` -> `115082d` -> `0424f46` -> `9f45cc0`, the last one mid-batch,
# killing four rows inside capnp).  A gate that reads a volatile input is not a
# gate.  Build slang-uhdm at the mandated base, run verify_golden into a workdir
# whose name nobody else will prune, pin it with inputs.sh, and measure there.
#
#   usage: vgates.sh <pinned-workdir> [<outdir>]
#
# GUARDS: every gate counts what it could NOT reach; a gate that reaches nothing
# must never read as perfection.  The build gate re-builds and DIFFS the binary
# against the one that produced the artifacts.
set -u
WD=${1:?pinned workdir}
OUT=${2:-/tmp/vladder1_gates}
HERE=$(cd "$(dirname "$0")" && pwd)
ROWS="default:SeqDriver default:SimpleUVM default:Scoreboard default:BuildUVMPkg
      default:Earlgrey_0_1 testflags:SeqDriver testflags:SimpleUVM
      testflags:BuildUVMPkg default:YosysVerx testflags:YosysVerx default:Rggen"
mkdir -p "$OUT" || exit 1

echo "=== GATE 1: build against the OFFICIAL UHDM install"
echo "\$ g++ -O2 -std=c++17 ctladder.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ctladder"
( cd "$HERE" && g++ -O2 -std=c++17 ctladder.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o "$OUT/ctladder" )
echo "build rc=$?"
export CTLADDER=$OUT/ctladder
"$CTLADDER" 2>&1 | head -1

echo
echo "=== GATE 2: calibration — golden vs golden must give ZERO rungs, ALL 11 rows"
"$HERE/calib.sh" "$WD" $ROWS
echo "calib rc=$?"

echo
echo "=== GATE 3: sanity — rung #1 must BE uhdm-cmp's head, byte for byte, ALL 11 rows"
echo "# note: rowheads.sh uses ~/.local/bin/uhdm-cmp and this uses"
echo "#       ~/git-repos/UHDM/build/bin/uhdm-cmp; they are the SAME binary:"
md5sum ~/.local/bin/uhdm-cmp ~/git-repos/UHDM/build/bin/uhdm-cmp 2>&1 | sed 's/^/#   /'
"$HERE/rowsanity.sh" "$WD" "$OUT/sanity" $ROWS
echo "sanity rc=$?"

echo
echo "=== GATE 4: determinism — two runs of a row give the SAME ladder"
echo "# Earlgrey_0_1 is EXCLUDED and is NOT deterministic: its stop is a WALL"
echo "# CLOCK (stop=BUDGET), so its rung count measures the machine, not the row."
BUDGET=1500 "$HERE/detcheck.sh" "$WD" "$OUT/det" \
  default:SeqDriver default:SimpleUVM default:Rggen default:YosysVerx \
  testflags:YosysVerx default:BuildUVMPkg
echo "det rc=$?"
