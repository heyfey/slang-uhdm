#!/usr/bin/env bash
# r10oth3 arm driver.  Runs Surelog and slang-uhdm on ONE purpose-built source
# from this directory, dumps both databases, cmps them, and prints the
# `assignment` vpiOpType + Rhs FORM per object per module view (DEF =
# uhdmallModules, ELAB = uhdmtopModules) side by side.
#
#   usage:  SLANG_UHDM=/path/to/build/slang-uhdm ./carm.sh c1_compound.sv [workdir]
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# SLANG_UHDM has NO DEFAULT on purpose: scripts/verify_golden.py:52 and
# tests/check_goldens.sh:5 both default it to the MAIN-TREE binary, and a
# wrong-binary measurement is indistinguishable from a real pass.  Prove your
# export with the negative control -- SLANG_UHDM=/bin/false must FAIL all 23
# goldens.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SRC=$1
D=${2:-/tmp/r10oth3_arm_$(basename "$SRC" .sv)}
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse -nobuiltin -nocache "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$SLANG_UHDM" "$SRC" --nobuiltin -o slang.uhdm >slang.log 2>&1
# uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING (it prints "File does not
# exist!" and returns success), so without this guard the cmp below would print
# PASS_CMP on a slang run that produced nothing.
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -8 slang.log; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump              # RHS ours
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && echo PASS_CMP || echo CMP_FAIL
echo "cmp heads(^LHS: at col 0) = $(grep -c '^LHS:' cmp.log)"
diff -u g.dump o.dump > d.diff && echo DUMP_MATCH || \
    echo "DUMP_DIFF $(grep -c '^[-+]' d.diff) (content+2: counts the two diff -u header lines)"
# --expect 1 is the POSITIVE CONTROL: if the instrument finds no assignment at
# all it exits 3 rather than printing an empty, reassuring table.
python3 "$HERE/asgform.py" --expect 1 g.dump > g.asg || { echo INSTRUMENT_BLIND_GOLDEN; exit 4; }
python3 "$HERE/asgform.py" --expect 1 o.dump > o.asg || { echo INSTRUMENT_BLIND_OURS; exit 4; }
echo "--- assignment Rhs forms: < golden(Surelog)   > ours ---"
diff g.asg o.asg || true
echo "WD=$D"
