#!/usr/bin/env bash
# v11u32 face runner: one tiny design per FACE, both binaries, official uhdm-cmp.
# Usage: bash /tmp/v11u32_face.sh <dir-with-*.sv> [extra-slang-args]
# Prints: <face> sl=<rc> pris=<rc/verdict> pat=<rc/verdict>
set -u
D=${1:?dir}
SUR=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
for f in "$D"/*.sv; do
  n=$(basename "$f" .sv)
  w="$D/run_$n"; rm -rf "$w"; mkdir -p "$w"; cp "$f" "$w/"
  ( cd "$w" && timeout 300 "$SUR" -parse -nobuiltin -nocache -sv -d uhdm "$n.sv" > sl.log 2>&1 )
  slrc=$?
  g="$w/slpp_all/surelog.uhdm"
  if [ ! -f "$g" ]; then echo "$n SURELOG_NO_DB rc=$slrc"; continue; fi
  ( cd "$w" && timeout 300 "$BIN_PRIS" "$n.sv" --single-unit --nobuiltin -o p.uhdm > p.log 2>&1 ); prc=$?
  ( cd "$w" && timeout 300 "$BIN_PAT"  "$n.sv" --single-unit --nobuiltin -o q.uhdm > q.log 2>&1 ); qrc=$?
  pv=REJECT; qv=REJECT
  if [ -f "$w/p.uhdm" ]; then timeout 300 "$CMP" "$g" "$w/p.uhdm" > "$w/pc.log" 2>&1; pv=$([ $? -eq 0 ] && echo EQUAL || echo NOTEQUAL); fi
  if [ -f "$w/q.uhdm" ]; then timeout 300 "$CMP" "$g" "$w/q.uhdm" > "$w/qc.log" 2>&1; qv=$([ $? -eq 0 ] && echo EQUAL || echo NOTEQUAL); fi
  flag=""
  [ "$pv" = EQUAL ] && [ "$qv" != EQUAL ] && flag="  <<<< REGRESSION"
  [ "$pv" != EQUAL ] && [ "$qv" = EQUAL ] && flag="  ++++ CONVERT"
  echo "$n slrc=$slrc prisrc=$prc patrc=$qrc  PRIS=$pv PAT=$qv$flag"
done
