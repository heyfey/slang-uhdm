#!/usr/bin/env bash
# r10uvm82 VERIFIER arm driver.  LHS is ALWAYS golden (Surelog); RHS is ours.
#   usage: SLANG_UHDM=<bin> ./v82arm.sh <src.sv> [workdir]
# Guards carried from r10earl29repro/arm.sh: uhdm-cmp exits 0 on a missing input;
# uhdm-dump's first line is the DB path; Surelog writes builtin.sv into CWD.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/v82_arm_$B}
: "${SLANG_UHDM:?set SLANG_UHDM}"
[ -x "$SLANG_UHDM" ] || { echo "FATAL: no such binary $SLANG_UHDM"; exit 9; }
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/$(basename $SRC)" "$D/" 2>/dev/null || cp "$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse -nocache -mt 0 -mp 0 "$(basename $SRC)" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -8 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
[ -s g.dump ] || { echo "NO_GOLDEN_DUMP $B"; exit 7; }
"$SLANG_UHDM" "$(basename $SRC)" -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo "NO_OUTPUT $B"; tail -8 slang.log; exit 6; }
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
[ -s o.dump ] || { echo "NO_OURS_DUMP $B"; exit 7; }
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && R=PASS_CMP || R=CMP_FAIL
H=$(grep -c '^LHS:' cmp.log); [ -z "$H" ] && H=0
L=$(wc -l < cmp.log)
if diff -u g.dump o.dump > d.diff; then DD=DUMP_MATCH
else DD="DUMP_DIFF content=$(grep -E '^[-+]' d.diff | grep -vcE '^(---|\+\+\+) ')"; fi
printf "%-10s %-9s heads=%-4s lines=%-7s %s\n" "$B" "$R" "$H" "$L" "$DD"
echo "  WD=$D"
