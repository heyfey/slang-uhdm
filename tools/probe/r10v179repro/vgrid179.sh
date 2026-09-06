#!/usr/bin/env bash
# r10v179repro/vgrid179.sh — the VERIFIER's arm driver.  MEASUREMENT ONLY; the
# official uhdm-cmp is the sole judge of equality.
#   vgrid179.sh <file.sv> <binPRIS> <binPAT> <workdir>
# Builds the Surelog golden and BOTH frozen binaries' databases in BOTH views,
# echoes every command WITH ITS BINARY PATH and its rc into <workdir>/cmds.txt
# (an rc=139 segfault must never read as a result), and runs uhdm-dump on all
# six databases plus the official judge on each arm-view.
set -u
SV=$(readlink -f "$1"); A=$(readlink -f "$2"); B=$(readlink -f "$3"); W=$4
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  for pair in "$G:g" "$W/a_$v.uhdm:a" "$W/b_$v.uhdm:b"; do
    f=${pair%:*}; tg=${pair##*:}
    if [ -f "$f" ]; then
      "$DUMP" "$f" > "$W/dump.$tg.$v.txt" 2>>"$W/dump.err"
      echo "dump rc=$? $tg $v lines=$(wc -l < "$W/dump.$tg.$v.txt")" >> "$W/cmds.txt"
    else : > "$W/dump.$tg.$v.txt"; echo "dump MISSING $tg $v" >> "$W/cmds.txt"; fi
  done
  for s in a b; do
    if [ -f "$G" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CMP" "$G" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
      echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt" || true)" >> "$W/cmds.txt"
    else echo "cmp MISSING $s $v" >> "$W/cmds.txt"; fi
  done
done
grep -c '^rc=0' "$W/cmds.txt"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0'; true
grep '^cmp ' "$W/cmds.txt"; true
