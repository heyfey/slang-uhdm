#!/usr/bin/env bash
# r10oth7 arm driver.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: SLANG_UHDM=/path/to/build/slang-uhdm ./ctarm.sh c1_builtins.sv [wd]
#
# DIFFERENT FROM r10oth6's viarm.sh IN ONE LOAD-BEARING WAY: builtins are ON.
# r10oth6 ran every arm with `-nobuiltin`, which DELETES `mailbox`, `semaphore`
# and `process` from both sides and so cannot see half A of this pass at all.
# Set NOBUILTIN=1 to get the old behaviour for a control.
#
# SLANG_UHDM has NO DEFAULT on purpose: scripts/verify_golden.py and
# tests/check_goldens.sh both default it to the MAIN-TREE binary, which has
# burned this campaign before.
#
# Ops traps this script ENCODES rather than documents:
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> `sed 1d`
#     on BOTH dumps.  Convention: content = `-`/`+` lines of `diff -u` MINUS
#     diff's own `---`/`+++` header (two separate traps; both handled).
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING -> the `[ -f ]` guards.
#   * Compare's m_visited short-circuit hides defects -> the JUDGE here is
#     `diff -u g.dump o.dump`; PASS_CMP is printed only as a side note.
#   * Surelog synthesizes builtin.sv AS A FILE IN THE CWD, so the arm runs in
#     its own scratch directory and both tools see the same path.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SRC=$1
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/r10oth7_arm_$B}
SLFLAG=""; OURFLAG=""
if [ "${NOBUILTIN:-0}" = 1 ]; then SLFLAG="-nobuiltin"; OURFLAG="--nobuiltin"; fi
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse $SLFLAG -nocache "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$SLANG_UHDM" "$SRC" $OURFLAG -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -8 slang.log; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump              # RHS ours
[ -s g.dump ] && [ -s o.dump ] || { echo NO_DUMP; exit 7; }
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && echo PASS_CMP || echo CMP_FAIL
echo "cmp lines=$(wc -l < cmp.log) (HEAD DEPTH ONLY)"
if diff -u g.dump o.dump > d.diff; then
  echo DUMP_MATCH
else
  echo "DUMP_DIFF content=$(grep -E '^[-+]' d.diff | grep -vcE '^(---|\+\+\+) ') hunks=$(grep -c '^@@' d.diff)"
fi
echo "unsupported(ours): $(grep -c '^  ' slang.log 2>/dev/null || echo 0)"
echo "WD=$D"
