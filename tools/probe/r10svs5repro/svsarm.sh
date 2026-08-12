#!/bin/bash
# r10svs5repro/svsarm.sh — run ONE arm .sv through both tools and report.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  uhdm-cmp takes
# (golden.uhdm, ours.uhdm) in that order.
#
#   usage: svsarm.sh <arm.sv> <outdir> <slang-binary> [class method]...
#     With trailing (class, method) pairs it also prints the svsstmts statement
#     census for each, which is THE instrument for this pass: the head is a
#     `begin` and `begin::Compare` compares only BaseClass + the Stmts LIST, so a
#     statement-list length is the only thing that can fail on it.
#
# GUARDS (every one an ops trap this campaign has paid for):
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING -- both databases are
#     existence-checked before cmp runs; a missing one is a hard exit 6, never a
#     verdict.
#   * uhdm-dump's FIRST LINE is the DATABASE PATH and always differs -- both
#     dumps go through `sed 1d`.
#   * the slang binary is a REQUIRED argument, never defaulted to the main-tree
#     build; its path and md5 are printed on every run.
#   * surelog / uhdm-cmp / uhdm-dump are existence-checked and absolute.
#   * `-nobuiltin` on both sides: the builtin classes otherwise dominate the
#     dump and Surelog's and slang's builtin models are not the thing under test.
set -u
ARM=${1:?arm .sv}
OUT=${2:?outdir}
BIN=${3:?slang binary}
shift 3
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CENSUS=/tmp/r10svs5_svsstmts

[ -f "$ARM" ] || { echo "FATAL: no arm $ARM"; exit 3; }
[ -x "$BIN" ] || { echo "FATAL: slang not executable: $BIN"; exit 3; }
[ -x "$SL" ] || { echo "FATAL: surelog not executable: $SL"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: uhdm-cmp not executable: $CMP"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: uhdm-dump not executable: $DUMP"; exit 3; }

ARM=$(cd "$(dirname "$ARM")" && pwd)/$(basename "$ARM")
echo "ARM=$ARM"
echo "SLANG=$BIN  md5=$(md5sum "$BIN" | cut -d' ' -f1)"
mkdir -p "$OUT" || exit 1
rm -f "$OUT/ours.uhdm"
"$SL" -parse -d uhdm -nobuiltin "$ARM" -mt 0 -mp 0 -o "$OUT" > "$OUT/surelog.log" 2>&1
echo "surelog rc=$?"
"$BIN" -nobuiltin "$ARM" -o "$OUT/ours.uhdm" > "$OUT/slang.log" 2>&1
echo "slang rc=$?"

G=$(ls "$OUT"/slpp_all/*.uhdm 2>/dev/null | head -1)
O=$OUT/ours.uhdm
[ -n "${G:-}" ] && [ -f "$G" ] || { echo "NO_OUTPUT: golden absent (see $OUT/surelog.log)"; exit 6; }
[ -f "$O" ] || { echo "NO_OUTPUT: ours absent (see $OUT/slang.log)"; exit 6; }
echo "golden bytes=$(stat -c %s "$G")  ours bytes=$(stat -c %s "$O")"

"$DUMP" "$G" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/g.dump" 2>&1
"$DUMP" "$O" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/o.dump" 2>&1
[ -s "$OUT/g.dump" ] || { echo "NO_OUTPUT: golden dump empty"; exit 6; }
[ -s "$OUT/o.dump" ] || { echo "NO_OUTPUT: ours dump empty"; exit 6; }
RAW=$(diff -u "$OUT/g.dump" "$OUT/o.dump" | grep -c '^[-+]')
echo "dump content +/- = $((RAW - 2))  (raw $RAW minus 2 diff -u headers)"
"$CMP" "$G" "$O" > "$OUT/cmp.txt" 2>&1
echo "cmp rc=$?  cmp HEAD DEPTH=$(wc -l < "$OUT/cmp.txt")  heads=$(grep -c '^LHS:' "$OUT/cmp.txt")"

while [ $# -ge 2 ]; do
    echo "-- census $1 :: $2"
    [ -x "$CENSUS" ] || { echo "FATAL: build svsstmts first (svsbuild.sh svsstmts)"; exit 3; }
    "$CENSUS" "$G" "$O" "$1" "$2"
    shift 2
done
echo "GOLDEN=$G"
echo "OURS=$O"
echo "OUT=$OUT"
