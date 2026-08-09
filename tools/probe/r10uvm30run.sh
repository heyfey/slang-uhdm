#!/bin/bash
# r10uvm30run.sh <armdir> — build golden + ours for one purpose-built arm and
# print the r10uvm30io io_decl FORMAL census of both, side by side.
#   SLANG_UHDM=<build> R10IO=/tmp/r10uvm30io tools/probe/r10uvm30run.sh <arm>
# Outputs go to /tmp/r10uvm30arm/<arm-leaf>/ — NEVER into the repo tree.
set -u
A=$(cd "${1:?arm dir}" && pwd)
L=$(basename "$A")
O=${OUTROOT:-/tmp/r10uvm30arm}/$L
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
SU=${SLANG_UHDM:?export SLANG_UHDM}
V=${R10IO:-/tmp/r10uvm30io}
rm -rf "$O"; mkdir -p "$O"
( cd "$O" && "$SL" -parse -d uhdm "$A/dut.sv" > sl.log 2>&1 )
"$SU" "$A/dut.sv" -o "$O/ours.uhdm" > "$O/ours.log" 2>&1
GF="$O/slpp_all/surelog.uhdm"
[ -f "$GF" ] || { echo "no golden: $GF"; tail -20 "$O/sl.log"; exit 1; }
[ -f "$O/ours.uhdm" ] || { echo "no ours"; tail -20 "$O/ours.log"; exit 1; }
"$V" "$GF" > "$O/g.io"
"$V" "$O/ours.uhdm" > "$O/o.io"
echo "== golden vs ours io_decl formals ($L)"
diff "$O/g.io" "$O/o.io"
echo "== (full census in $O/{g,o}.io)"
