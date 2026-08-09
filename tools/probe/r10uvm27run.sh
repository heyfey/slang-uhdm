#!/bin/bash
# r10uvm27run.sh <armdir> — build golden + ours for one purpose-built arm.
# Leaves golden at $A/out/slpp_all/surelog.uhdm and ours at $A/out/ours.uhdm,
# plus uhdm-dump text for both.
#   SLANG_UHDM=<build> tools/probe/r10uvm27run.sh tools/probe/r10uvm27repro/t37a
set -u
A=$(cd "${1:?arm dir}" && pwd)
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
SU=${SLANG_UHDM:?export SLANG_UHDM}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
rm -rf "$A/out"; mkdir -p "$A/out"
( cd "$A/out" && "$SL" -parse -d uhdm ../dut.sv > sl.log 2>&1 )
"$SU" "$A/dut.sv" -o "$A/out/ours.uhdm" > "$A/out/ours.log" 2>&1
G="$A/out/slpp_all/surelog.uhdm"
[ -f "$G" ] || { echo "no golden: $G"; tail -5 "$A/out/sl.log"; exit 1; }
"$DUMP" "$G" > "$A/out/g.dump" 2>&1
"$DUMP" "$A/out/ours.uhdm" > "$A/out/o.dump" 2>&1
echo "golden=$G  ours=$A/out/ours.uhdm"
echo "dumps: $A/out/g.dump $A/out/o.dump"
