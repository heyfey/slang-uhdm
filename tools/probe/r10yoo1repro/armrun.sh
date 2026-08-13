#!/usr/bin/env bash
# r10yoo1 ARM RUNNER -- runs Surelog AND a slang-uhdm binary on one arm file and
# prints the param_assign Rhs-constant typespec census, GOLDEN vs OURS, cell for
# cell.
#
#   usage: ./armrun.sh <arm.v> <slang-binary>
#
# The Surelog argv is the harness's `default` mode shape, so an arm answer is
# comparable with a corpus answer: `-parse` (what makes Surelog emit a database
# at all) plus `-mt 0 -mp 0` for determinism, and NOTHING that shapes the model.
# slang gets `--single-unit` for the same reason the harness gives it: Surelog's
# default is one compilation unit.
#
# TRAPS ENCODED:
#  * a missing database is a HARD EXIT, never an empty table -- an empty census
#    reads exactly like a census where every cell agrees.
#  * Surelog is run in its own directory and the database located by search,
#    because Surelog picks its own filename under -o.
set -u
ARM=${1:?arm .v file}
BIN=${2:?slang binary}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
PA=${PA:-/tmp/r10yoo1pa}
[ -f "$ARM" ] || { echo "FATAL: no arm file $ARM"; exit 3; }
[ -x "$BIN" ] || { echo "FATAL: not executable $BIN"; exit 3; }
[ -x "$SURELOG" ] || { echo "FATAL: no surelog $SURELOG"; exit 3; }
[ -x "$PA" ] || { echo "FATAL: no census probe $PA (build r10yoo1pa.cpp)"; exit 3; }
BASE=$(basename "$ARM" .v)
D=$(mktemp -d /tmp/r10yoo1_arm_${BASE}_XXXX)
cp "$ARM" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse "$BASE.v" -mt 0 -mp 0 -o slout > sl.log 2>&1
G=$(find slout -name '*.uhdm' | head -1)
[ -n "$G" ] && [ -f "$G" ] || { echo "FATAL: surelog produced no database for $BASE"; tail -20 sl.log; exit 6; }
"$BIN" "$BASE.v" --single-unit -o ours.uhdm > su.log 2>&1
[ -f ours.uhdm ] || { echo "FATAL: slang produced no database for $BASE"; tail -20 su.log; exit 7; }
echo "===== ARM $BASE   golden=$G"
"$PA" "$G" ours.uhdm "|"
echo "ARMDIR $D"
