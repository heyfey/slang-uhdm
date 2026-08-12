#!/bin/bash
# r10uvm62repro/arm62.sh — build ONE arm's GOLDEN (Surelog) and OURS (slang-uhdm)
# database from a single .sv in THIS directory, dump both, cmp both.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  uhdm-cmp takes
# (golden.uhdm, ours.uhdm) in that order and every run prints that it did.
#
#   usage: arm.sh <arm.sv> <outdir> [slang-binary]
#
# GUARDS, each one an ops trap this campaign has paid for:
#   * uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING, so both databases are
#     existence-checked BEFORE cmp runs and a missing one is exit 6, never a
#     verdict.
#   * uhdm-dump's FIRST LINE is the DATABASE PATH and always differs; both
#     dumps go through `sed 1d`.  The "dump content +/-" figure is
#     raw-minus-2 where the 2 is ONLY diff -u's two header lines.
#   * the slang binary is never silently defaulted: its path and md5 print.
#   * surelog is run in a PER-ARM directory so concurrent arms cannot share
#     slpp_all.
set -u
SV=${1:?arm .sv}
OUT=${2:?outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
BIN=${3:?slang binary (never defaulted)}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -f "$HERE/$SV" ] || { echo "FATAL: no $HERE/$SV"; exit 3; }
for t in "$BIN" "$SL" "$CMP" "$DUMP"; do
  [ -x "$t" ] || { echo "FATAL: not executable: $t"; exit 3; }
done
echo "ARM=$SV"
echo "SLANG=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
echo "CMP=$CMP (golden first, ours second)  DUMP=$DUMP"
rm -rf "$OUT"; mkdir -p "$OUT" || exit 1
cd "$OUT" || exit 1
"$SL" -parse -d uhdm -nobuiltin "$HERE/$SV" > "$OUT/surelog.log" 2>&1
echo "surelog rc=$?"
"$BIN" -nobuiltin "$HERE/$SV" -o "$OUT/ours.uhdm" > "$OUT/slang.log" 2>&1
echo "slang rc=$?"
G=$OUT/slpp_all/surelog.uhdm
O=$OUT/ours.uhdm
[ -f "$G" ] || { echo "NO_OUTPUT: golden $G absent"; exit 6; }
[ -f "$O" ] || { echo "NO_OUTPUT: ours $O absent"; exit 6; }
echo "golden bytes=$(stat -c %s "$G")  ours bytes=$(stat -c %s "$O")"
"$DUMP" "$G" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/g.dump" 2>&1
"$DUMP" "$O" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/o.dump" 2>&1
[ -s "$OUT/g.dump" ] || { echo "NO_OUTPUT: golden dump empty"; exit 6; }
[ -s "$OUT/o.dump" ] || { echo "NO_OUTPUT: ours dump empty"; exit 6; }
RAW=$(diff -u "$OUT/g.dump" "$OUT/o.dump" | grep -c '^[-+]')
echo "g.dump=$(wc -l < "$OUT/g.dump") o.dump=$(wc -l < "$OUT/o.dump")  dump content +/- = $((RAW-2))"
"$CMP" "$G" "$O" > "$OUT/cmp.txt" 2>&1
echo "cmp rc=$?  cmp lines=$(wc -l < "$OUT/cmp.txt")  heads=$(grep -c '^LHS:' "$OUT/cmp.txt")"
echo "OUT=$OUT"
