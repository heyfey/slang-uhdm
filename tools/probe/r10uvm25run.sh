#!/bin/bash
# r10uvm25run.sh <armdir> — build golden + ours for one purpose-built arm and
# diff the CLASS typedef listings (§ typedefAliasSharesTypespec25).
#   tools/probe/r10uvm25run.sh tools/probe/r10uvm25repro/t35a
set -u
A=$(cd "${1:?arm dir}" && pwd)
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
SU=${SLANG_UHDM:?export SLANG_UHDM}
B=${R10B:-/tmp/r10uvm25b}
rm -rf "$A/out"; mkdir -p "$A/out"
( cd "$A/out" && "$SL" -parse -d uhdm ../dut.sv > sl.log 2>&1 )
"$SU" "$A/dut.sv" -o "$A/out/ours.uhdm" > "$A/out/ours.log" 2>&1
G="$A/out/slpp_all/surelog.uhdm"
[ -f "$G" ] || { echo "no golden: $A/out/slpp_all/surelog.uhdm"; tail -5 "$A/out/sl.log"; exit 1; }
"$B" "$G" | grep " ts\[" | sed 's/\[[0-9]*\]//' > "$A/out/g.txt"
"$B" "$A/out/ours.uhdm" | grep " ts\[" | sed 's/\[[0-9]*\]//' > "$A/out/o.txt"
echo "=== golden ==="; cat "$A/out/g.txt"
echo "=== diff (golden vs ours) ==="
diff "$A/out/g.txt" "$A/out/o.txt" && echo IDENTICAL
