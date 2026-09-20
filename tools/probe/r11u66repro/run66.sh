#!/bin/bash
# r11u66 arm driver — run ONE arm file through Surelog v1.87 (golden) and one
# slang-uhdm binary, dump both, record BOTH rc values and the golden's [ERR
# count.  usage: run66.sh <file.sv> <tag> [binary]
# GRID=<dir> selects where the arms live (default: this script's directory).
set -u
F=$(readlink -f "${1:?file}"); TAG=${2:?tag}
BIN=${3:-${SLANG_UHDM:?set SLANG_UHDM or pass the binary as $3}}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
D=$(dirname "$F"); N=$(basename "$F" .sv)
rm -rf "$D/g_$N"; mkdir -p "$D/g_$N"
( cd "$D/g_$N" && "$SL" -parse -nobuiltin -nocache -sv "$F" -mt 0 -mp 0 -o . > sl.log 2>&1 ); grc=$?
rm -rf "$D/o_${N}_$TAG"; mkdir -p "$D/o_${N}_$TAG"
( cd "$D/o_${N}_$TAG" && "$BIN" "$F" --single-unit -o ours.uhdm > our.log 2>&1 ); orc=$?
G=$(ls "$D"/g_$N/slpp_all/*.uhdm 2>/dev/null | head -1)
echo "ARM $N tag=$TAG slrc=$grc ourrc=$orc slerr=$(grep -c '\[ERR' "$D/g_$N/sl.log" 2>/dev/null; true)"
[ -n "$G" ] && "$DUMP" "$G" | sed "s#$D##g" > "$D/$N.g.dump" 2>&1
[ -f "$D/o_${N}_$TAG/ours.uhdm" ] &&
  "$DUMP" "$D/o_${N}_$TAG/ours.uhdm" | sed "s#$D##g" > "$D/$N.$TAG.dump" 2>&1
echo "  gdump=$( [ -s "$D/$N.g.dump" ] && wc -l < "$D/$N.g.dump" || echo NONE)" \
     "odump=$( [ -s "$D/$N.$TAG.dump" ] && wc -l < "$D/$N.$TAG.dump" || echo NONE)"
[ "$orc" = 0 ] || echo "  *** OUR COMPILE FAILED — this arm teaches ERROR RECOVERY, not golden ***"
[ "$grc" = 0 ] || echo "  *** GOLDEN COMPILE FAILED — not a golden ***"
