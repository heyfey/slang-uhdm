#!/usr/bin/env bash
# arm.sh <workdir/mode> <binary> <outdir> <names...>
# Re-runs ONE sweep row with a chosen binary — the row's OWN slang command line
# out of its cmds.txt, our binary, our output path — and judges it with the
# OFFICIAL uhdm-cmp against that row's own golden.  rc is RECORDED, never
# swallowed (a rc=139 reads as SLANG_REJECT in the harness).
set -u
WD=$1; BIN=$2; OUT=$3; shift 3
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
UC=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
mkdir -p "$OUT"
for n in "$@"; do
  d=$(ls -d "$WD"/"$n"-* 2>/dev/null | head -1)
  [ -z "$d" ] && { echo "$n MISSING-ROW"; continue; }
  cmd=$(grep '^slang:' "$d/cmds.txt" | sed 's/^slang: *//')
  gold=$(grep '^surelog:' "$d/cmds.txt" | sed 's/.*golden cache hit \(.*\))/\1/')
  [ -d "$gold" ] || gold=$(dirname "$d")/"$n"-*/slpp_all
  newcmd=$(echo "$cmd" | sed "s#^[^ ]*#$BIN#; s#-o [^ ]*#-o $OUT/$n.uhdm#")
  ( cd "$d" && eval "$newcmd" > "$OUT/$n.slang.log" 2>&1 )
  src=$?
  g=$(find "$gold" -name 'surelog.uhdm' | head -1)
  "$UC" "$g" "$OUT/$n.uhdm" > "$OUT/$n.cmp.txt" 2> "$OUT/$n.cmp.err"
  crc=$?
  echo "$n slang_rc=$src cmp_rc=$crc heads=$(grep -c '^LHS:' "$OUT/$n.cmp.err" 2>/dev/null; true) cmplines=$(wc -l < "$OUT/$n.cmp.err")"
done
