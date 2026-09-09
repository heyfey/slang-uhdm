#!/bin/bash
# r11vu3 GRID RUNNER (verifier of r11u3 § structParamMemberOvBinary).
# Builds the golden with the pinned Surelog v1.87 and ours with a chosen
# binary, then judges with the official uhdm-cmp (golden LHS, ours RHS).
#
#   usage: OUT=<scratch dir> ./run.sh <grid> <slang-uhdm binary> <tag>
#          (OUT defaults to /tmp/r11vu3_out; nothing is written into the repo)
#
# The `--nobuiltin` on OUR side mirrors the `-nobuiltin` the golden side gets;
# without it every grid carries a spurious builtin-class head (measured).
set -u
SL=${SUERLOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
D=$1; BIN=${2:-}; TAG=${3:-x}
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
W=${OUT:-/tmp/r11vu3_out}/$D/out_$TAG
rm -rf "$W"; mkdir -p "$W"
( cd "$ROOT/$D" && "$SL" -parse -nobuiltin -nocache -sv -mt 0 -mp 0 \
      -o "$W/g" dut.sv > "$W/sl.log" 2>&1 )
G=$(ls "$W"/g/slpp_all/*.uhdm 2>/dev/null | head -1)
echo "SL err=$(grep -o '\[ *ERROR\] *: *[0-9]*' "$W/sl.log" | tail -1) golden=$G"
if [ -n "$BIN" ]; then
    ( cd "$ROOT/$D" && "$BIN" --nobuiltin dut.sv --single-unit \
          -o "$W/ours.uhdm" > "$W/ours.log" 2>&1 )
    echo "OURS rc=$?"
    if [ -f "$W/ours.uhdm" ]; then
        "$CMP" "$G" "$W/ours.uhdm" > "$W/cmp.txt" 2>&1
        echo "CMP rc=$? heads=$(grep -c '^LHS:' "$W/cmp.txt"; true) lines=$(wc -l < "$W/cmp.txt")"
    fi
fi
