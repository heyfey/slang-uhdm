#!/usr/bin/env bash
# r10v160repro/varm160.sh — THE VERIFIER'S ARM DRIVER.  For one .sv file and
# both views, build the GOLDEN database (Surelog) and BOTH our databases, then
# run the OFFICIAL uhdm-cmp golden-vs-ours on each.  MEASUREMENT ONLY; LHS is
# ALWAYS golden.  Every command is echoed with its binary PATH into cmds.txt
# and every cell records its own rc (rc=139 must never read as a result).
#   varm160.sh <file.sv> <bin A (pristine)> <bin B (patched)> <workdir>
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; local r=$?; echo "rc=$r $*" >> "$W/cmds.txt"; return $r; }
BN=$(basename "$SV" .sv)
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"; echo "ARC $v a rc=$?" >> "$W/rcs.txt"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"; echo "ARC $v b rc=$?" >> "$W/rcs.txt"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  for side in a b; do
    OF="$W/${side}_$v.uhdm"
    if [ ! -f "$G" ]; then echo "$BN $v $side SKIP-NOGOLDEN" ; continue; fi
    if [ ! -f "$OF" ]; then echo "$BN $v $side SKIP-NOOURS"; continue; fi
    "$CMP" "$G" "$OF" > "$W/cmp.$side.$v.out" 2> "$W/cmp.$side.$v.err"
    echo "cmp rc=$? $side $v" >> "$W/cmds.txt"
    L=$(cat "$W/cmp.$side.$v.out" "$W/cmp.$side.$v.err" | wc -l)
    H=$(grep -c '^LHS:' "$W/cmp.$side.$v.err" 2>/dev/null; true)
    D=$(grep -cE '^DESIGN.*CMP_EQUAL' "$W/cmp.$side.$v.out" 2>/dev/null; true)
    echo "$BN $v $side lines=$L heads=$H eq=$D"
  done
done
