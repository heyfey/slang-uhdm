#!/bin/bash
# r10uvm45 — run gold.sh on an arm and diff the two databases' LISTING vectors
# (r10uvm44ls) in one call, because that projection is the whole point of an arm
# built for § modulePublishesPackageClasses45.
#   usage: armls.sh <arm> <outdir> [slang-binary]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ARM=${1:?}
OUT=${2:?}
V=/tmp/r10uvm45_r10uvm44ls
[ -x "$V" ] || { echo "FATAL: probe $V missing"; exit 3; }
# An arm keeps its BIRTH pass's directory — t62a is this pass's, t61a is pass
# 44's, t60a/t60b pass 43's — so resolve it across the sibling repro dirs
# instead of copying the source into every later pass (a duplicated arm is a
# second copy of a spec that can drift from the one the golden was cut from).
ARMDIR=""
for d in "$HERE" "$HERE"/../r10uvm4*repro; do
  [ -f "$d/$ARM/dut.sv" ] && { ARMDIR=$(cd "$d" && pwd); break; }
done
[ -n "$ARMDIR" ] || { echo "FATAL: arm $ARM not found under tools/probe/*repro"; exit 3; }
"$ARMDIR"/gold.sh "$ARM" "$OUT" "${3:-}" | tail -4
G=$OUT/slpp_all/surelog.uhdm
O=$OUT/ours.uhdm
"$V" "$G" > "$OUT/ls_golden.txt"
"$V" "$O" > "$OUT/ls_ours.txt"
# A driver that cannot find its input reports perfection.
for f in "$OUT/ls_golden.txt" "$OUT/ls_ours.txt"; do
  [ -s "$f" ] || { echo "FATAL: $f EMPTY"; exit 3; }
done
echo "golden scopes=$(wc -l < "$OUT/ls_golden.txt") ours scopes=$(wc -l < "$OUT/ls_ours.txt")"
if diff "$OUT/ls_golden.txt" "$OUT/ls_ours.txt"; then
  echo "LISTINGS IDENTICAL"
else
  echo "listing diff lines=$(diff "$OUT/ls_golden.txt" "$OUT/ls_ours.txt" | grep -c '^[<>]')"
fi
