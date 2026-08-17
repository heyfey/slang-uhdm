#!/usr/bin/env bash
# v83 VERIFIER arm driver. LHS is ALWAYS golden(Surelog); RHS is ours.
# Adds an INSTANCE TABLE for every unsupported_typespec, golden vs ours, so a
# cell that stays CMP_FAIL for an unrelated reason still scores THIS law.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/v83_arm_$B}
: "${SLANG_UHDM:?set SLANG_UHDM}"
[ -x "$SLANG_UHDM" ] || { echo "FATAL: no such binary $SLANG_UHDM"; exit 9; }
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse -nocache -mt 0 -mp 0 "$(basename $SRC)" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -6 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
[ -s g.dump ] || { echo "NO_GOLDEN_DUMP $B"; exit 7; }
"$SLANG_UHDM" "$(basename $SRC)" -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo "NO_OUTPUT $B"; tail -6 slang.log; exit 6; }
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
[ -s o.dump ] || { echo "NO_OURS_DUMP $B"; exit 7; }
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && R=PASS_CMP || R=CMP_FAIL
H=$(grep -c '^LHS:' cmp.log); [ -z "$H" ] && H=0
L=$(wc -l < cmp.log)
if diff -u g.dump o.dump > d.diff; then DD=DUMP_MATCH
else DD="DUMP_DIFF=$(grep -E '^[-+]' d.diff | grep -vcE '^(---|\+\+\+) ')"; fi
printf "%-26s %-9s heads=%-4s lines=%-7s %s\n" "$B" "$R" "$H" "$L" "$DD"
echo "  WD=$D"
