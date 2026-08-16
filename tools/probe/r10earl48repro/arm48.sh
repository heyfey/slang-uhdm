#!/usr/bin/env bash
# r10earl48 arm driver (carried forward verbatim from r10earl40repro/arm40.sh).  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: SLANG_UHDM=/abs/path/to/build/slang-uhdm ./arm47.sh a1_earl48.sv [workdir]
#
# Carried forward verbatim from tools/probe/r10earl30repro/arm30.sh; the ops traps
# encoded here are the ones this campaign paid for:
#   * SLANG_UHDM has NO DEFAULT — a stale-binary reading has burned this campaign
#     more than once, and both harness scripts default it to the MAIN TREE.
#     The md5 of the binary under test is PRINTED on every arm run.
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> `sed 1d`
#     on BOTH dumps.
#   * uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING -> explicit -f/-x guards, so a
#     missing input is fatal instead of silently green.
#   * cmp line count is HEAD DEPTH, never a distance; the diff is the judge.
#   * Surelog synthesizes builtin.sv AS A FILE IN THE CWD, so every arm runs in
#     its own scratch dir and both tools see identical paths.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/r10earl48_arm_$B}
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
[ -x "$SLANG_UHDM" ] || { echo "FATAL: no such binary $SLANG_UHDM"; exit 9; }
for t in "$SURELOG" "$DUMP" "$CMP"; do
  [ -x "$t" ] || { echo "FATAL: no such tool $t"; exit 9; }
done
echo "BINARY $SLANG_UHDM md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1)"
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse -nocache -mt 0 -mp 0 "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
[ -s g.dump ] || { echo NO_GOLDEN_DUMP; exit 7; }
"$SLANG_UHDM" "$SRC" -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -8 slang.log; exit 6; }
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump                # RHS ours
[ -s o.dump ] || { echo NO_OURS_DUMP; exit 7; }
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && echo PASS_CMP || echo CMP_FAIL
echo "cmp heads=$(grep -c '^LHS:' cmp.log) lines=$(wc -l < cmp.log) (HEAD DEPTH ONLY)"
if diff -u g.dump o.dump > d.diff; then
  echo DUMP_MATCH
else
  echo "DUMP_DIFF content=$(grep -E '^[-+]' d.diff | grep -vcE '^(---|\+\+\+) ') hunks=$(grep -c '^@@' d.diff)"
fi
echo "WD=$D"
