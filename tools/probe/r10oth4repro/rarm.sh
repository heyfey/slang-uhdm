#!/usr/bin/env bash
# r10oth4 arm driver -- the WORKING replication-constant driver that r10oth3's
# residue R1 lacked.  r10oth3's carm.sh exits INSTRUMENT_BLIND_GOLDEN on a
# continuous-`assign` arm (asgform.py hunts procedural `assignment` objects,
# of which such an arm has ZERO) and darm.sh/rangeform.py read packed RANGES.
# This one reads CONSTANTS via replform.py, whose --expect is a real positive
# control (exit 3, not an empty reassuring table).
#
#   usage: SLANG_UHDM=/path/to/build/slang-uhdm ./rarm.sh d3_replwidth.v [wd]
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# SLANG_UHDM has NO DEFAULT on purpose: scripts/verify_golden.py:52 and
# tests/check_goldens.sh:5 both default it to the MAIN-TREE binary.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
EXPECT=${EXPECT:-1}
SRC=$1
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/r10oth4_arm_$B}
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse -nobuiltin -nocache "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$SLANG_UHDM" "$SRC" --nobuiltin -o slang.uhdm >slang.log 2>&1
# uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING, so this guard is not optional.
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -8 slang.log; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump              # RHS ours
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && echo PASS_CMP || echo CMP_FAIL
echo "cmp heads(^LHS: at col 0) = $(grep -c '^LHS:' cmp.log)"
diff -u g.dump o.dump > d.diff && echo DUMP_MATCH || \
  echo "DUMP_DIFF $(grep -c '^[-+]' d.diff) (content+2: includes the two diff -u header lines)"
python3 "$HERE/replform.py" --expect "$EXPECT" g.dump > g.rep || { echo INSTRUMENT_BLIND_GOLDEN; exit 4; }
python3 "$HERE/replform.py" --expect "$EXPECT" o.dump > o.rep || { echo INSTRUMENT_BLIND_OURS; exit 4; }
echo "--- constants: golden(LHS) ---"; cat g.rep
echo "--- constants: ours(RHS) ---";   cat o.rep
echo "--- diff  (< golden(LHS) / > ours(RHS)) ---"; diff g.rep o.rep || true
echo "WD=$D"
