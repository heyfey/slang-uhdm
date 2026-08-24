#!/usr/bin/env bash
# r10vbuvm33 varm33.sh — one arm, BOTH views, golden + BOTH binaries, dumps +
# the official uhdm-cmp on each side.  Every command with its rc into cmds.txt.
#   varm33.sh <file.sv> <workdir>   (PRIS and PATCH env vars = frozen binaries)
set -u
SV=$(readlink -f "$1"); W=$2
: "${PRIS:?}"; : "${PATCH:?}"
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$W"; : > "$W/cmds.txt"
run(){ echo "$*" >>"$W/cmds.txt"; "$@" >/dev/null 2>&1; echo "rc=$? $*" >>"$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$PRIS"  "$SV" $EF -o "$W/p_$v.uhdm"
  run "$PATCH" "$SV" $EF -o "$W/q_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  "$DUMP" "$G"           > "$W/dump.g.$v.txt" 2>&1
  "$DUMP" "$W/p_$v.uhdm" > "$W/dump.p.$v.txt" 2>&1
  "$DUMP" "$W/q_$v.uhdm" > "$W/dump.q.$v.txt" 2>&1
  "$CMP" "$G" "$W/p_$v.uhdm" > "$W/cmp.p.$v.txt" 2>&1
  "$CMP" "$G" "$W/q_$v.uhdm" > "$W/cmp.q.$v.txt" 2>&1
  echo "$v: pris cmp=$(wc -l < "$W/cmp.p.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.p.$v.txt" || true) | patched cmp=$(wc -l < "$W/cmp.q.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.q.$v.txt" || true)"
done
