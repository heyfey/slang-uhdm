#!/bin/bash
# r10uvm26run.sh <armdir> — build golden + ours for one purpose-built arm and
# diff the r10uvm26v census (package AND module views).
#   R10V=/tmp/r10uvm26v tools/probe/r10uvm26run.sh tools/probe/r10uvm26repro/t36a
set -u
A=$(cd "${1:?arm dir}" && pwd)
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
SU=${SLANG_UHDM:?export SLANG_UHDM}
V=${R10V:?set R10V to an r10uvm26v build}
rm -rf "$A/out"; mkdir -p "$A/out"
( cd "$A/out" && "$SL" -parse -d uhdm ../dut.sv > sl.log 2>&1 )
"$SU" "$A/dut.sv" -o "$A/out/ours.uhdm" > "$A/out/ours.log" 2>&1
G="$A/out/slpp_all/surelog.uhdm"
[ -f "$G" ] || { echo "no golden: $G"; tail -5 "$A/out/sl.log"; exit 1; }
"$V" "$G" | sed 's/var\[[0-9]*\]/var/' > "$A/out/g.txt"
"$V" "$A/out/ours.uhdm" | sed 's/var\[[0-9]*\]/var/' > "$A/out/o.txt"
echo "=== golden ==="; cat "$A/out/g.txt"
echo "=== diff (golden vs ours) ==="
diff "$A/out/g.txt" "$A/out/o.txt" && echo IDENTICAL
