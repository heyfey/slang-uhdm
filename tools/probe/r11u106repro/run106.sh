#!/bin/bash
# r11u106 arm driver (run104.sh + the range-bound walker + uhdm-cmp per tag).
# Golden runs ONCE per arm (GFORCE=1 re-runs).  Every run records slrc/ourrc/
# slerr; TAGS MUST BE THE SAME LENGTH.  Outputs next to the arm:
#   <arm>.g.dump/.g.tw  golden;  <arm>.<tag>.dump/.<tag>.tw/.<tag>.cmp  ours.
# usage: run106.sh <file.sv> <tag>=<binary> [...]      (TW106=<walker binary>)
set -u
F=$(readlink -f "${1:?file}"); shift
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
TW=${TW106:-/tmp/r11u106_tw}
D=$(dirname "$F"); N=$(basename "$F" .sv)
if [ "${GFORCE:-0}" = 1 ] || [ ! -s "$D/$N.g.dump" ]; then
  rm -rf "$D/g_$N"; mkdir -p "$D/g_$N"
  ( cd "$D/g_$N" && "$SL" -parse -nobuiltin -nocache -sv "$F" -mt 0 -mp 0 -o . > sl.log 2>&1 ); echo $? > "$D/g_$N/rc"
  G=$(ls "$D"/g_$N/slpp_all/*.uhdm 2>/dev/null | head -1)
  [ -n "$G" ] && timeout 300 "$DUMP" "$G" 2>&1 | sed "s#$D##g" > "$D/$N.g.dump"
  [ -n "$G" ] && "$TW" "$G" | sed 's/#[0-9]*//g' > "$D/$N.g.tw"
fi
G=$(ls "$D"/g_$N/slpp_all/*.uhdm 2>/dev/null | head -1)
grc=$(cat "$D/g_$N/rc" 2>/dev/null || echo NA)
for tb in "$@"; do
  TAG=${tb%%=*}; BIN=${tb#*=}
  rm -rf "$D/o_${N}_$TAG"; mkdir -p "$D/o_${N}_$TAG"
  ( cd "$D/o_${N}_$TAG" && "$BIN" "$F" --single-unit -o ours.uhdm > our.log 2>&1 ); orc=$?
  rm -f "$D/$N.$TAG.dump" "$D/$N.$TAG.tw" "$D/$N.$TAG.cmp"
  O="$D/o_${N}_$TAG/ours.uhdm"
  if [ -f "$O" ]; then
    timeout 300 "$DUMP" "$O" 2>&1 | sed "s#$D##g" > "$D/$N.$TAG.dump"
    "$TW" "$O" | sed 's/#[0-9]*//g' > "$D/$N.$TAG.tw"
    [ -n "$G" ] && "$CMP" "$G" "$O" > "$D/$N.$TAG.cmp" 2>&1
  fi
  echo "ARM $N tag=$TAG slrc=$grc ourrc=$orc slerr=$(grep -c '\[ERR' "$D/g_$N/sl.log" 2>/dev/null; true) cmplines=$(wc -l < "$D/$N.$TAG.cmp" 2>/dev/null || echo NA) heads=$(grep -c '^LHS:' "$D/$N.$TAG.cmp" 2>/dev/null; true)"
done
