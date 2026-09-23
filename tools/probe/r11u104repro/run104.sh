#!/bin/bash
# r11u104 arm driver — r11u86's run66.sh with the golden run ONCE per arm
# (re-used while its dump exists) and any number of <tag>=<binary> pairs.
# Every run records slrc / ourrc / slerr.  TAGS MUST BE THE SAME LENGTH
# (dump paths embed the workdir; the dumps are path-normalised anyway).
# usage: run104.sh <file.sv> <tag>=<binary> [<tag>=<binary> ...]
#        GFORCE=1 re-runs the golden.
set -u
F=$(readlink -f "${1:?file}"); shift
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
D=$(dirname "$F"); N=$(basename "$F" .sv)
if [ "${GFORCE:-0}" = 1 ] || [ ! -s "$D/$N.g.dump" ]; then
  rm -rf "$D/g_$N"; mkdir -p "$D/g_$N"
  ( cd "$D/g_$N" && "$SL" -parse -nobuiltin -nocache -sv "$F" -mt 0 -mp 0 -o . > sl.log 2>&1 ); echo $? > "$D/g_$N/rc"
  G=$(ls "$D"/g_$N/slpp_all/*.uhdm 2>/dev/null | head -1)
  [ -n "$G" ] && timeout 300 "$DUMP" "$G" 2>&1 | sed "s#$D##g" > "$D/$N.g.dump"
fi
grc=$(cat "$D/g_$N/rc" 2>/dev/null || echo NA)
for tb in "$@"; do
  TAG=${tb%%=*}; BIN=${tb#*=}
  rm -rf "$D/o_${N}_$TAG"; mkdir -p "$D/o_${N}_$TAG"
  ( cd "$D/o_${N}_$TAG" && "$BIN" "$F" --single-unit -o ours.uhdm > our.log 2>&1 ); orc=$?
  rm -f "$D/$N.$TAG.dump"
  [ -f "$D/o_${N}_$TAG/ours.uhdm" ] &&
    timeout 300 "$DUMP" "$D/o_${N}_$TAG/ours.uhdm" 2>&1 | sed "s#$D##g" > "$D/$N.$TAG.dump"
  echo "ARM $N tag=$TAG slrc=$grc ourrc=$orc slerr=$(grep -c '\[ERR' "$D/g_$N/sl.log" 2>/dev/null; true) gdump=$( [ -s "$D/$N.g.dump" ] && wc -l < "$D/$N.g.dump" || echo NONE) odump=$( [ -s "$D/$N.$TAG.dump" ] && wc -l < "$D/$N.$TAG.dump" || echo NONE)"
done
