#!/usr/bin/env bash
# r10v180 verifier arm driver — grid180.sh with the DEF and ELAB views kept
# SEPARATE (grid180.sh cats them into one file and score180.py keys on the
# path alone, so the def rows collide with the elab rows and the last writer
# wins).  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#   vgrid180.sh <file.sv> <binA:pristine> <binB:patched> <workdir> <cen bin>
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4; CEN=$5
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:cen.g.$v.txt" "a_$v.uhdm:cen.a.$v.txt" "b_$v.uhdm:cen.b.$v.txt"; do
    f=${pair%%:*}; out=${pair#*:}
    if [ -f "$W/$f" ]; then "$CEN" "$W/$f" "V.$v" > "$W/$out" 2>>"$W/cen.err"; echo "cen rc=$? $f" >> "$W/cmds.txt"
    else : > "$W/$out"; echo "cen MISSING $f" >> "$W/cmds.txt"; fi
  done
  for s in a b; do
    if [ -f "$W/g_$v/slpp_all/surelog.uhdm" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CMP" "$W/g_$v/slpp_all/surelog.uhdm" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
      echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt")" >> "$W/cmds.txt"
    else
      echo "cmp MISSING $s $v" >> "$W/cmds.txt"
    fi
  done
done
grep '^cmp ' "$W/cmds.txt"; true
grep -v '^rc=0' "$W/cmds.txt" | grep '^rc=' ; true
