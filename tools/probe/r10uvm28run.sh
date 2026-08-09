#!/bin/bash
# r10uvm28run.sh <armdir> — build golden + ours for one purpose-built arm and
# print the r10uvm28g reference-BINDING census of both, side by side.
#   SLANG_UHDM=<build> R10G=/tmp/r10uvm28g tools/probe/r10uvm28run.sh <arm>
set -u
A=$(cd "${1:?arm dir}" && pwd)
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
SU=${SLANG_UHDM:?export SLANG_UHDM}
G=${R10G:-/tmp/r10uvm28g}
rm -rf "$A/out"; mkdir -p "$A/out"
( cd "$A/out" && "$SL" -parse -d uhdm ../dut.sv > sl.log 2>&1 )
"$SU" "$A/dut.sv" -o "$A/out/ours.uhdm" > "$A/out/ours.log" 2>&1
GF="$A/out/slpp_all/surelog.uhdm"
[ -f "$GF" ] || { echo "no golden: $GF"; tail -5 "$A/out/sl.log"; exit 1; }
"$G" "$GF" > "$A/out/g.bind"
"$G" "$A/out/ours.uhdm" > "$A/out/o.bind"
echo "== golden vs ours reference bindings ($A)"
diff "$A/out/g.bind" "$A/out/o.bind"
echo "== (diff above; full census in $A/out/{g,o}.bind)"
