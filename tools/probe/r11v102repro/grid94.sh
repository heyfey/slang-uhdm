#!/bin/bash
# r11v102 grid driver (a copy of r11u102repro/grid102.sh) — ONE golden per arm (real Surelog v1.87), then each
# frozen binary; every arm records slrc / ourrc / slerr.  Tags are FOUR chars.
# usage: grid102.sh <arm.sv> <tag>:<binary> [<tag>:<binary> ...]
set -u
F=$(readlink -f "${1:?arm}"); shift
D=$(dirname "$F"); N=$(basename "$F" .sv)
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
if [ ! -s "$D/$N.g.dump" ]; then
  rm -rf "$D/g_$N"; mkdir -p "$D/g_$N"
  ( cd "$D/g_$N" && "$SL" -parse -nobuiltin -nocache -sv "$F" -mt 0 -mp 0 -o . > sl.log 2>&1 ); echo $? > "$D/g_$N/rc"
  G=$(ls "$D"/g_$N/slpp_all/*.uhdm 2>/dev/null | head -1)
  [ -n "$G" ] && "$DUMP" "$G" | sed "s#$D##g" > "$D/$N.g.dump"
fi
grc=$(cat "$D/g_$N/rc"); gerr=$(grep -c '\[ERR' "$D/g_$N/sl.log"; true)
for tb in "$@"; do
  TAG=${tb%%:*}; BIN=${tb#*:}
  rm -rf "$D/o_${N}_$TAG"; mkdir -p "$D/o_${N}_$TAG"
  ( cd "$D/o_${N}_$TAG" && "$BIN" "$F" --single-unit -o ours.uhdm > our.log 2>&1 ); orc=$?
  [ -f "$D/o_${N}_$TAG/ours.uhdm" ] && "$DUMP" "$D/o_${N}_$TAG/ours.uhdm" | sed "s#$D##g" > "$D/$N.$TAG.dump"
  echo "ARM $N tag=$TAG slrc=$grc ourrc=$orc slerr=$gerr"
done
