#!/usr/bin/env bash
# r10earl63 — run ONE grid .sv through Surelog (golden) and a slang-uhdm
# binary, then census both param_assign tables with pacen63.
#   usage: SLANG_UHDM=/abs/bin ./run63.sh <file.sv> <outdir> [--elabuhdm]
# Ops traps encoded: SLANG_UHDM has no default and is echoed with its md5;
# Surelog runs -nobuiltin -nocache; both censuses go through the SAME reader.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
PACEN=${PACEN63:-/tmp/r10earl63_pacen63}
F=$(readlink -f "${1:?file.sv}")
D=${2:?outdir}
EXTRA=${3:-}
: "${SLANG_UHDM:?set SLANG_UHDM}"
mkdir -p "$D" || exit 9
D=$(cd "$D" && pwd)
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm $EXTRA "$F" ) > "$D/sl.log" 2>&1
G="$D/slpp_all/surelog.uhdm"
[ -f "$G" ] || { echo "SURELOG_FAIL $F"; exit 6; }
( cd "$D" && "$SLANG_UHDM" $EXTRA "$F" -o "$D/ours.uhdm" ) > "$D/o.log" 2>&1
[ -f "$D/ours.uhdm" ] || { echo "SLANG_REJECT $F rc=$?"; tail -3 "$D/o.log"; exit 7; }
"$PACEN" "$G" | sort > "$D/gold.pa"
"$PACEN" "$D/ours.uhdm" | sort > "$D/ours.pa"
echo "OK $(basename "$F") gold=$(wc -l < "$D/gold.pa") ours=$(wc -l < "$D/ours.pa")"
