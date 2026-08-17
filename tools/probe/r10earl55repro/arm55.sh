#!/usr/bin/env bash
# r10earl55 arm driver — arm54.sh WITH `-elabuhdm` / `--elabuhdm` on BOTH sides.
#
# WHY THIS SCRIPT EXISTS AND WHY IT IS NOT arm54.sh
# -------------------------------------------------
# The r10earl55 target lives in Surelog's `NetlistElaboration::high_conn_`, and
# Earlgrey_0_1.sl is `+define+SYNTHESIS -f ...scr -elabuhdm -parse -d coveruhdm
# -verbose`, so the GOLDEN this pass must model is the ELABORATED one and this
# driver passes the flag on BOTH sides.  The first a1 run of this pass was made
# with arm54.sh (plain `-parse`) and read "golden does not fold", which is what
# this file is named after.
#
# CORRECTED AT INTEGRATION -- the REASON for that misread was not the one first
# written here.  A plain `-parse` golden does NOT "fold nothing": it contains
# BOTH listings (for a1_earl55.sv, 187 `module_inst` and 40 `ref_module`), and
# a nested replication in a port HighConn is FOLDED under the `module_inst`
# chain and KEPT under the `ref_module` chain.  The discriminator is
# `module_inst` vs `ref_module`, NOT elaborated vs plain; the first a1 read had
# been looking at the DEFINITION listing.  `-elabuhdm` is still correct and
# still required here (it is the mode the Earlgrey row runs in, and the only
# mode whose HighConns carry the instance-scoped ts fullnames this law mints),
# but do not repeat the claim that the plain view is blind to the law -- the
# wide boundary sweep shows the arm firing in BOTH views, and README.md's
# plain-view section measures BROKE=0 in both.
#
#   usage: SLANG_UHDM=/abs/path/build/slang-uhdm ./arm55.sh a1_earl55.sv [wd]
#
# Every trap arm54.sh encodes is kept verbatim:
#   * SLANG_UHDM has NO DEFAULT and its md5 is PRINTED on every run.
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH -> `sed 1d` on BOTH dumps.
#   * uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING -> explicit -f/-s guards.
#   * cmp LINE COUNT IS HEAD DEPTH, never a distance; the dump diff is the judge.
#   * Surelog synthesizes builtin.sv AS A FILE IN THE CWD, so each arm runs in
#     its own scratch dir and both tools see identical paths.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/r10earl55_arm_$B}
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
[ -x "$SLANG_UHDM" ] || { echo "FATAL: no such binary $SLANG_UHDM"; exit 9; }
for t in "$SURELOG" "$DUMP" "$CMP"; do
  [ -x "$t" ] || { echo "FATAL: no such tool $t"; exit 9; }
done
echo "BINARY $SLANG_UHDM md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1)"
rm -rf "$D"; mkdir -p "$D" || exit 9
if [ -f "$HERE/$SRC" ]; then cp "$HERE/$SRC" "$D/" || exit 9
else cp "$SRC" "$D/" || exit 9; fi
SRC=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -elabuhdm -nocache -mt 0 -mp 0 "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
[ -s g.dump ] || { echo NO_GOLDEN_DUMP; exit 7; }
"$SLANG_UHDM" --elabuhdm "$SRC" -o slang.uhdm >slang.log 2>&1
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
