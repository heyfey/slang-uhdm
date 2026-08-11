#!/usr/bin/env bash
# r10oth3 TARGET 2 arm driver.  Same shape as carm.sh but reads packed RANGE
# bound forms (rangeform.py) instead of assignment Rhs forms, because direction
# B's head is the left bound of a port's packed range.
#
#   usage: SLANG_UHDM=/path/to/slang-uhdm ./darm.sh d1_portrange.v [workdir]
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
# SLANG_UHDM has NO DEFAULT -- see carm.sh's header for why.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SRC=$1
D=${2:-/tmp/r10oth3_arm_$(basename "$SRC" .v)}
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse -nobuiltin -nocache "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$SLANG_UHDM" "$SRC" --nobuiltin -o slang.uhdm >slang.log 2>&1
# uhdm-cmp EXITS 0 ON A MISSING INPUT FILE, so this guard is what stops the cmp
# below printing PASS_CMP on a run that produced nothing.
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -8 slang.log; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump              # RHS ours
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && echo PASS_CMP || echo CMP_FAIL
echo "cmp heads(^LHS: at col 0) = $(grep -c '^LHS:' cmp.log)"
diff -u g.dump o.dump > d.diff && echo DUMP_MATCH || \
    echo "DUMP_DIFF $(grep -c '^[-+]' d.diff) (content+2: counts the two diff -u header lines)"
python3 "$HERE/rangeform.py" --expect 1 g.dump > g.rng || { echo INSTRUMENT_BLIND_GOLDEN; exit 4; }
python3 "$HERE/rangeform.py" --expect 1 o.dump > o.rng || { echo INSTRUMENT_BLIND_OURS; exit 4; }
echo "--- packed range bound forms: < golden(Surelog)   > ours ---"
diff g.rng o.rng || true
echo "WD=$D"
