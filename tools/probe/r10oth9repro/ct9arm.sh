#!/usr/bin/env bash
# r10oth9 arm driver.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: SLANG_UHDM=/path/to/build/slang-uhdm ./ct9arm.sh b1_ctrl.sv [wd]
#          GOLDEN_ONLY=1 ./ct9arm.sh b1_ctrl.sv     # golden side alone
#
# Carried forward from tools/probe/r10oth8repro/ct8arm.sh unchanged in substance;
# the ops traps it encodes are the ones this campaign paid for:
#   * SLANG_UHDM has NO DEFAULT.  verify_golden.py and check_goldens.sh both
#     default it to the MAIN-TREE binary, and a stale-binary reading has burned
#     this campaign more than once.
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> `sed 1d`
#     on BOTH dumps.  DUMP CONTENT here = the `-`/`+` lines of `diff -u` MINUS
#     diff's own `---`/`+++` header.  Two separate traps, both handled.
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING -> `[ -f ]`/`[ -s ]` guards,
#     so a missing input is fatal instead of silently green.
#   * Compare's m_visited short-circuit hides defects behind a head, so the JUDGE
#     is `diff -u g.dump o.dump`; the cmp line count is printed as HEAD DEPTH
#     only, never as a distance.
#   * Surelog synthesizes builtin.sv AS A FILE IN THE CWD, so each arm runs in
#     its own scratch directory and both tools see the same paths.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/r10oth9_arm_$B}
if [ "${GOLDEN_ONLY:-0}" != 1 ]; then : "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"; fi
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
[ -s g.dump ] || { echo NO_GOLDEN_DUMP; exit 7; }
if [ "${GOLDEN_ONLY:-0}" = 1 ]; then
  echo "GOLDEN_ONLY: no RHS measured; g.dump lines=$(wc -l < g.dump)  WD=$D"
  exit 0
fi
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
echo "unsupported(ours): $(grep -c '^  ' slang.log 2>/dev/null || echo 0)"
echo "WD=$D"
