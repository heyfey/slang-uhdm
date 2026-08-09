#!/bin/bash
# r10uvm29run.sh <armdir> — build golden + ours for one purpose-built arm and
# print the r10uvm29v class-property INITIALIZER census of both, side by side.
#   SLANG_UHDM=<build> R10V=/tmp/r10uvm29v tools/probe/r10uvm29run.sh <arm>
# Outputs go to /tmp/r10uvm29arm/<arm-leaf>/ — NEVER into the repo tree.
set -u
A=$(cd "${1:?arm dir}" && pwd)
L=$(basename "$A")
O=${OUTROOT:-/tmp/r10uvm29arm}/$L
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
SU=${SLANG_UHDM:?export SLANG_UHDM}
V=${R10V:-/tmp/r10uvm29v}
rm -rf "$O"; mkdir -p "$O"
( cd "$O" && "$SL" -parse -d uhdm "$A/dut.sv" > sl.log 2>&1 )
"$SU" "$A/dut.sv" -o "$O/ours.uhdm" > "$O/ours.log" 2>&1
GF="$O/slpp_all/surelog.uhdm"
[ -f "$GF" ] || { echo "no golden: $GF"; tail -20 "$O/sl.log"; exit 1; }
[ -f "$O/ours.uhdm" ] || { echo "no ours"; tail -20 "$O/ours.log"; exit 1; }
"$V" "$GF" > "$O/g.iv"
"$V" "$O/ours.uhdm" > "$O/o.iv"
echo "== golden vs ours class-property initializers ($L)"
diff "$O/g.iv" "$O/o.iv"
echo "== (full census in $O/{g,o}.iv)"
