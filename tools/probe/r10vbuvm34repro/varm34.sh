#!/usr/bin/env bash
# r10vbuvm34repro/varm34.sh — one arm, BOTH views, THREE sides (golden,
# pristine, patched).  Every command + rc echoed into <workdir>/cmds.txt so the
# binary each database came from is auditable BY PATH (RESUME §9).
#   varm34.sh <file.sv> <pristine-bin> <patched-bin> <workdir>
set -u
SV=$(readlink -f "$1"); PRIS=$(readlink -f "$2"); PAT=$(readlink -f "$3"); W=$4
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$W"; : > "$W/cmds.txt"
run(){ echo "CMD $*" >>"$W/cmds.txt"; "$@" >>"$W/out.txt" 2>&1; local r=$?; echo "rc=$r $*" >>"$W/cmds.txt"; return 0; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$PRIS" "$SV" $EF -o "$W/p_$v.uhdm"
  run "$PAT"  "$SV" $EF -o "$W/q_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  run "$DUMP" "$G"          ; "$DUMP" "$G"          > "$W/dump.g.$v.txt" 2>&1
  run "$DUMP" "$W/p_$v.uhdm"; "$DUMP" "$W/p_$v.uhdm" > "$W/dump.p.$v.txt" 2>&1
  run "$DUMP" "$W/q_$v.uhdm"; "$DUMP" "$W/q_$v.uhdm" > "$W/dump.q.$v.txt" 2>&1
  "$CMP" "$G" "$W/p_$v.uhdm" > "$W/cmp.p.$v.txt" 2>&1
  "$CMP" "$G" "$W/q_$v.uhdm" > "$W/cmp.q.$v.txt" 2>&1
  echo "$v: cmpP=$(wc -l < "$W/cmp.p.$v.txt") headsP=$(grep -c '^LHS:' "$W/cmp.p.$v.txt" || true) cmpQ=$(wc -l < "$W/cmp.q.$v.txt") headsQ=$(grep -c '^LHS:' "$W/cmp.q.$v.txt" || true)"
done
