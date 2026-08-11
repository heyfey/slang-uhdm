#!/usr/bin/env bash
# r10oth6 arm driver.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: SLANG_UHDM=/path/to/build/slang-uhdm ./viarm.sh v1_vifprop.sv [wd]
#
# SLANG_UHDM has NO DEFAULT on purpose: scripts/verify_golden.py:52 and
# tests/check_goldens.sh:5 both default it to the MAIN-TREE binary, which has
# burned this campaign before.
#
# Ops traps this script ENCODES rather than documents:
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> `sed 1d`
#     on BOTH dumps, so the content figure is not inflated by 2.
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING -> the `[ -f ]` guards.
#   * Compare's m_visited short-circuit hides defects -> the JUDGE here is
#     `diff -u g.dump o.dump`, and PASS_CMP is printed only as a side note.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SRC=$1
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/r10oth6_arm_$B}
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
echo "cmp lines=$(wc -l < cmp.log) heads=$(grep -c '^LHS:' cmp.log)"
if diff -u g.dump o.dump > d.diff; then
  echo DUMP_MATCH
else
  # CORRECTED BY THE r10oth6 VERIFIER.  This used to be `grep -c '^[-+]'`,
  # which ALSO counts diff -u's OWN `--- g.dump` / `+++ o.dump` header lines and
  # so over-reported content by EXACTLY 2 on every non-empty diff (measured:
  # 2715 raw vs 2713 real on SVSwitch).  `sed 1d` on the dumps kills the
  # database-path line; it does NOT kill the diff header.  Both are needed.
  echo "DUMP_DIFF content=$(grep -E '^[-+]' d.diff | grep -vcE '^(---|\+\+\+) ') hunks=$(grep -c '^@@' d.diff)"
fi
echo "unsupported(ours): $(grep -c '^  ' slang.log 2>/dev/null || echo 0)"
echo "WD=$D"
