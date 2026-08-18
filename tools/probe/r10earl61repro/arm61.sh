#!/usr/bin/env bash
# r10earl61 arm driver.  The Earlgrey_0_1 DEFAULT-mode row (this pass's head)
# runs Surelog with `-parse` ONLY and slang-uhdm with `--single-unit` only --
# NO `-elabuhdm` on either side (scripts/verify_golden.py's `default` branch) --
# and the elaborated tree is still present in both databases.  So the default
# arm here is the PLAIN one; `--elab` adds the flag to BOTH sides so the same
# grid can be read in the testflags shape too.
#
#   usage: SLANG_UHDM=/abs/path ./arm60.sh <arm.sv> [wd] [--elab]
#
# Traps encoded (each has burned this campaign):
#   * SLANG_UHDM has NO DEFAULT and its md5 is PRINTED on every run.
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH -> sed 1d on BOTH dumps.
#   * uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING -> explicit -f/-s guards.
#   * cmp LINE COUNT is HEAD DEPTH, never a distance; the dump diff is the judge.
#   * Surelog synthesizes builtin.sv AS A FILE IN THE CWD, so each arm runs in
#     its own scratch dir and both tools see identical paths.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/r10earl61_arm_$B}
ELAB=${3:-}
SLE=""; SUE=""
if [ "$ELAB" = "--elab" ]; then SLE="--elabuhdm"; SUE="-elabuhdm"; fi
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
[ -x "$SLANG_UHDM" ] || { echo "FATAL: no such binary $SLANG_UHDM"; exit 9; }
for t in "$SURELOG" "$DUMP" "$CMP"; do
  [ -x "$t" ] || { echo "FATAL: no such tool $t"; exit 9; }
done
echo "BINARY $SLANG_UHDM md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1) ELAB='${SUE:-none}'"
rm -rf "$D"; mkdir -p "$D" || exit 9
if [ -f "$HERE/$(basename "$SRC")" ]; then cp "$HERE/$(basename "$SRC")" "$D/" || exit 9
else cp "$SRC" "$D/" || exit 9; fi
SRC=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse $SUE -nocache -mt 0 -mp 0 "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
[ -s g.dump ] || { echo NO_GOLDEN_DUMP; exit 7; }
"$SLANG_UHDM" $SLE --single-unit "$SRC" -o slang.uhdm >slang.log 2>&1
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
