#!/bin/bash
# r10uvm55repro/wdump.sh — dump BOTH sides of ONE row out of a verify_golden
# workdir into an outdir as g.dump / o.dump, and print BOTH distance numbers
# (cmp lines / heads, and dump content +/-).
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  uhdm-cmp takes
# (golden.uhdm, ours.uhdm) in that order.
#
#   usage: wdump.sh <workdir> <TestName> <mode> <outdir>
#
# GUARDS (each an ops trap this campaign has paid for):
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING — both databases are
#     existence-checked FIRST and a missing one is exit 6, never a verdict.
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH, so both dumps go through
#     `sed '1d'`; the reported "dump content +/-" is RAW-minus-2 where the 2 is
#     ONLY the two `diff -u` header lines.  Convention stated on every run.
#   * the golden path is read out of the row's own cmds.txt and the golden CACHE
#     DIRECTORY is turned into .../golden.uhdm (handing uhdm-cmp a directory
#     compares nothing and still exits 0).
#   * cmp's OWN rc is captured immediately, not read after a $( ) substitution.
set -u
WD=${1:?workdir}
NAME=${2:?test name}
MODE=${3:?mode}
OUT=${4:?outdir}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
D=$(echo "$WD/$MODE/$NAME"-*/ | cut -d' ' -f1)
[ -d "$D" ] || { echo "FATAL: no row dir for $NAME/$MODE under $WD"; exit 3; }
O=$D/slang.uhdm
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
[ -f "$G" ] || { echo "NO_OUTPUT: golden absent (${G:-none})"; exit 6; }
[ -f "$O" ] || { echo "NO_OUTPUT: ours absent ($O)"; exit 6; }
mkdir -p "$OUT" || exit 1
echo "ROW=$D"
echo "golden=$G bytes=$(stat -c %s "$G")"
echo "ours  =$O bytes=$(stat -c %s "$O")"
"$DUMP" "$G" | sed '1d' > "$OUT/g.dump" 2>&1
"$DUMP" "$O" | sed '1d' > "$OUT/o.dump" 2>&1
[ -s "$OUT/g.dump" ] || { echo "NO_OUTPUT: golden dump empty"; exit 6; }
[ -s "$OUT/o.dump" ] || { echo "NO_OUTPUT: ours dump empty"; exit 6; }
echo "g.dump lines=$(wc -l < "$OUT/g.dump")  o.dump lines=$(wc -l < "$OUT/o.dump")"
RAW=$(diff -u "$OUT/g.dump" "$OUT/o.dump" | grep -c '^[-+]')
echo "dump content +/- = $((RAW - 2))   (raw $RAW minus the 2 diff -u header lines; line 1 already stripped by sed '1d')"
"$CMP" "$G" "$O" > "$OUT/cmp.txt" 2>&1
crc=$?
echo "cmp rc=$crc  cmp lines=$(wc -l < "$OUT/cmp.txt")  heads=$(grep -c '^LHS:' "$OUT/cmp.txt")"
echo "OUT=$OUT"
