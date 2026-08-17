#!/usr/bin/env bash
# r10earl57 — PLAIN-VIEW arm driver.  arm55.sh passes `-elabuhdm`/`--elabuhdm`;
# this one passes NEITHER, so the same three-way census can be taken in the
# plain view.  earl54's integration note is the reason it exists: the
# discriminator for these laws is `module_inst` vs `ref_module`, NOT elaborated
# vs plain, so BOTH views must be measured or the pass is claiming a fence it
# never looked at.
#
#   usage: SLANG_UHDM=/abs/path ./armplain55.sh <arm.sv> [wd]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/r10earl57_plain_$B}
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
[ -x "$SLANG_UHDM" ] || { echo "FATAL: no such binary $SLANG_UHDM"; exit 9; }
[ -x "$SURELOG" ] || { echo "FATAL: no surelog $SURELOG"; exit 9; }
echo "BINARY $SLANG_UHDM md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1)"
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/$(basename "$SRC")" "$D/" 2>/dev/null || cp "$SRC" "$D/" || exit 9
SRC=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache -mt 0 -mp 0 "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -5 surelog.log; exit 5; }
"$SLANG_UHDM" "$SRC" -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -5 slang.log; exit 6; }
echo "WD=$D"
