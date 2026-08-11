#!/usr/bin/env bash
# r10oth5 arm driver.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: SLANG_UHDM=/path/to/build/slang-uhdm ./parm.sh p1_paramref.v [wd]
#
# SLANG_UHDM has NO DEFAULT on purpose: scripts/verify_golden.py:52 and
# tests/check_goldens.sh:5 both default it to the MAIN-TREE binary, which has
# burned this campaign before.
#
# Three ops traps this script encodes rather than documents:
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> `sed 1d`
#     on BOTH dumps, so the content figure is not inflated by 2.
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING -> the `[ -f ]` guards.
#   * an instrument that reads nothing must FAIL, not reassure -> caform's
#     --expect is a real positive control (exit 3).
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
EXPECT=${EXPECT:-50}
SRC=$1
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/r10oth5_arm_$B}
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse -nobuiltin -nocache "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$SLANG_UHDM" "$SRC" --nobuiltin -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -8 slang.log; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump              # RHS ours
[ -s g.dump ] && [ -s o.dump ] || { echo NO_DUMP; exit 7; }
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && echo PASS_CMP || echo CMP_FAIL
echo "cmp heads(^LHS: at col 0) = $(grep -c '^LHS:' cmp.log)"
if diff -u g.dump o.dump > d.diff; then
  echo DUMP_MATCH
else
  echo "DUMP_DIFF content=$(( $(grep -c '^[-+]' d.diff) - 2 )) hunks=$(grep -c '^@@' d.diff)"
fi
python3 "$HERE/caform.py" --expect "$EXPECT" g.dump > g.tab || { echo INSTRUMENT_BLIND_GOLDEN; exit 4; }
python3 "$HERE/caform.py" --expect "$EXPECT" o.dump > o.tab || { echo INSTRUMENT_BLIND_OURS; exit 4; }
echo "rows: golden(LHS)=$(wc -l < g.tab) ours(RHS)=$(wc -l < o.tab)"
echo "WD=$D"
