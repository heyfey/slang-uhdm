#!/usr/bin/env bash
# varm32.sh <file.sv> <workdir> — golden Surelog + pristine + patched, BOTH views.
set -u
SV=$(readlink -f "$1"); W=$(readlink -m "$2")
PRIS=/tmp/vbuvm32_bin/pris32.bin; PAT=/tmp/vbuvm32_bin/pat32.bin
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
rm -rf "$W"; mkdir -p "$W"; : > "$W/cmds.txt"
run(){ echo "$*" >>"$W/cmds.txt"; "$@" >/dev/null 2>&1; echo "rc=$? $*" >>"$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$PRIS" "$SV" $EF -o "$W/pris_$v.uhdm"
  run "$PAT"  "$SV" $EF -o "$W/pat_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  [ -s "$G" ] && "$DUMP" "$G" > "$W/d.g.$v.txt" 2>&1
  [ -s "$W/pris_$v.uhdm" ] && "$DUMP" "$W/pris_$v.uhdm" > "$W/d.pris.$v.txt" 2>&1
  [ -s "$W/pat_$v.uhdm" ]  && "$DUMP" "$W/pat_$v.uhdm"  > "$W/d.pat.$v.txt" 2>&1
  if [ -s "$G" ]; then
    [ -s "$W/pris_$v.uhdm" ] && "$CMP" "$G" "$W/pris_$v.uhdm" > "$W/cmp.pris.$v.txt" 2>&1
    [ -s "$W/pat_$v.uhdm" ]  && "$CMP" "$G" "$W/pat_$v.uhdm"  > "$W/cmp.pat.$v.txt"  2>&1
  fi
  echo "$v: G=$( [ -s "$G" ] && echo ok || echo MISSING) prisRC=$(grep -c "^rc=0 $PRIS" "$W/cmds.txt";true) cmpPRIS=$(wc -l < "$W/cmp.pris.$v.txt" 2>/dev/null || echo NA)/$(grep -c '^LHS:' "$W/cmp.pris.$v.txt" 2>/dev/null||true) cmpPAT=$(wc -l < "$W/cmp.pat.$v.txt" 2>/dev/null || echo NA)/$(grep -c '^LHS:' "$W/cmp.pat.$v.txt" 2>/dev/null||true)"
done
