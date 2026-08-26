#!/bin/bash
# r10uvm159 — RE-MEASURE A BOUNDARY MOVER AGAINST GOLDEN.
# The wide boundary only says an arm's BYTES moved; this says WHICH WAY.
# For each named arm source it builds golden (Surelog, the SAME binary
# scripts/verify_golden.py uses) and both of ours, then scores the classified
# constant/typespec census on each side.  MEASUREMENT ONLY.
#
#   usage: PRIS=.. PATCHED=.. remeasure159.sh <outdir> <arm.sv> [<arm.sv> ...]
set -u
OUT=$(readlink -f "${1:?outdir}"); shift
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CLS=${CLS:-/tmp/wt_r10uvm159/tools/probe/r10uvm159repro/ct159cls}
mkdir -p "$OUT"
for f in "$@"; do
  [ -f "$f" ] || { echo "REMEASURE $f MISSING-SOURCE"; continue; }
  key=$(echo "${f#/}" | tr '/' '_')
  d=$OUT/$key; rm -rf "$d"; mkdir -p "$d"
  cp "$f" "$d/dut.sv"
  for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do [ -f "$h" ] && cp "$h" "$d/"; done
  ( cd "$d" && timeout 900 "$SURELOG" -parse -noprecompiledcache -nocache -mt 0 -mp 0 \
       dut.sv -o "$d/sl" > sl.log 2>&1 ); grc=$?
  ( cd "$d" && "$PRIS"    dut.sv -o p.uhdm > p.log 2>&1 </dev/null ); prc=$?
  ( cd "$d" && "$PATCHED" dut.sv -o q.uhdm > q.log 2>&1 </dev/null ); qrc=$?
  G=$d/sl/slpp_all/surelog.uhdm
  echo "REMEASURE $f grc=$grc prc=$prc qrc=$qrc golden=$([ -f "$G" ] && echo yes || echo NO)"
  [ -f "$G" ] || continue
  [ -f "$d/p.uhdm" ] && "$CLS" "$G" "$d/p.uhdm" --tag="PRIS:$key" | grep -E 'TALLY|SUM'
  [ -f "$d/q.uhdm" ] && "$CLS" "$G" "$d/q.uhdm" --tag="PAT :$key" | grep -E 'TALLY|SUM'
done
