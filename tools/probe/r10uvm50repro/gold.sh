#!/bin/bash
# r10uvm50repro/gold.sh — regenerate ONE arm's GOLDEN database with the
# git-repos Surelog binary, and our own database for the same source with a
# chosen slang binary, then dump and cmp both.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  uhdm-cmp takes
# (golden.uhdm, ours.uhdm) in that order.
#
#   usage: gold.sh <arm-dir-under-r10uvm50repro> <outdir> [slang-binary]
#
# GUARDS (each one is an ops trap this campaign has actually paid for):
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING, so a bare
#     `uhdm-cmp a b && echo PASS` prints PASS on a run that produced NOTHING.
#     Both databases are existence-checked before cmp runs, and a missing one
#     is a hard NO_OUTPUT/exit 6 rather than a verdict.
#   * the slang binary is never defaulted to the MAIN-TREE build silently: the
#     resolved path and its md5 are printed on every run.
# +2 BIAS FIXED AT INTEGRATION (found by the pass-50 verifier, confirmed by the
# master). uhdm-dump's FIRST LINE is the DATABASE PATH, which always differs
# between golden and ours, so it contributes one `-` and one `+` to every
# `diff -u`. Drivers that reported `grep -c '^[-+]'` minus 2 (subtracting only
# the ---/+++ headers) were therefore over-counting content by EXACTLY 2. Master
# verified on a real arm: raw 48, raw-2 = 46, TRUE content = 44. Both dumps are
# now piped through `sed '1d'` -- the same thing tests/check_goldens.sh already
# does -- so every figure from this driver is real content.
set -u
ARM=${1:?arm dir name}
OUT=${2:?outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE"/../../.. && pwd)
BIN=${3:-$ROOT/build/slang-uhdm}
SL=$HOME/git-repos/Surelog/build/bin/surelog

[ -d "$HERE/$ARM" ] || { echo "FATAL: no arm dir $HERE/$ARM"; exit 3; }
[ -f "$HERE/$ARM/dut.sv" ] || { echo "FATAL: no $HERE/$ARM/dut.sv"; exit 3; }
[ -x "$BIN" ] || { echo "FATAL: slang binary not executable: $BIN"; exit 3; }
[ -x "$SL" ] || { echo "FATAL: surelog not executable: $SL"; exit 3; }

echo "ARM=$ARM"
echo "SLANG=$BIN  md5=$(md5sum "$BIN" | cut -d' ' -f1)"

mkdir -p "$OUT" || exit 1
cd "$OUT" || exit 1

"$SL" -parse -d uhdm -nobuiltin "$HERE/$ARM/dut.sv" > "$OUT/surelog.log" 2>&1
echo "surelog rc=$?"
"$BIN" -nobuiltin "$HERE/$ARM/dut.sv" -o "$OUT/ours.uhdm" > "$OUT/slang.log" 2>&1
echo "slang rc=$?"

G=$OUT/slpp_all/surelog.uhdm
O=$OUT/ours.uhdm
[ -f "$G" ] || { echo "NO_OUTPUT: golden $G absent"; exit 6; }
[ -f "$O" ] || { echo "NO_OUTPUT: ours $O absent"; exit 6; }
echo "golden bytes=$(stat -c %s "$G")  ours bytes=$(stat -c %s "$O")"

uhdm-dump "$G" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/g.dump" 2>&1
uhdm-dump "$O" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/o.dump" 2>&1
[ -s "$OUT/g.dump" ] || { echo "NO_OUTPUT: golden dump empty"; exit 6; }
[ -s "$OUT/o.dump" ] || { echo "NO_OUTPUT: ours dump empty"; exit 6; }
echo "g.dump lines=$(wc -l < "$OUT/g.dump")  o.dump lines=$(wc -l < "$OUT/o.dump")"

uhdm-cmp "$G" "$O" > "$OUT/cmp.txt" 2>&1
echo "cmp rc=$?  cmp lines=$(wc -l < "$OUT/cmp.txt")  heads=$(grep -c '^LHS:' "$OUT/cmp.txt")"
echo "OUT=$OUT"
