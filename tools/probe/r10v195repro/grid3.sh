#!/usr/bin/env bash
# r10v195 — three-binary arm driver: golden x pristine x patched x FIXED.
set -u
SV=$(readlink -f "$1"); W=$2
A=${PRIS:?set PRIS to the pristine binary}
B=${PAT:?set PAT to the implementer patched binary}
C=${FIX:?set FIX to the verified binary}
CEN=${CEN:?set CEN to the built ct195cen}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SELFALL=${SELFALL:?set SELFALL to the built ct195selfall}
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  run "$C" "$SV" $EF -o "$W/c_$v.uhdm"
  "$CEN" "$W/g_$v/slpp_all/surelog.uhdm" g > "$W/cen.g.$v.txt" 2>/dev/null
  for s in a b c; do
    "$CEN" "$W/${s}_$v.uhdm" "$s" > "$W/cen.$s.$v.txt" 2>/dev/null
    "$CMP" "$W/g_$v/slpp_all/surelog.uhdm" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
    echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt") SELF=$("$SELFALL" "$W/${s}_$v.uhdm" | sed 's/.*SELF=//')" >> "$W/cmds.txt"
  done
  echo "gold SELF: $("$SELFALL" "$W/g_$v/slpp_all/surelog.uhdm")" >> "$W/cmds.txt"
done
echo "--- nonzero rcs:"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0 ' ; true
grep -E '^cmp |^gold SELF' "$W/cmds.txt"
for v in def elab; do
  echo "--- $v pristine->patched:"; python3 "$(dirname "$0")/score195v.py" "$W/cen.g.$v.txt" "$W/cen.a.$v.txt" "$W/cen.b.$v.txt" | tail -1
  echo "--- $v pristine->FIXED:";  python3 "$(dirname "$0")/score195v.py" "$W/cen.g.$v.txt" "$W/cen.a.$v.txt" "$W/cen.c.$v.txt" | tail -1
  echo "--- $v patched->FIXED:";   python3 "$(dirname "$0")/score195v.py" "$W/cen.g.$v.txt" "$W/cen.b.$v.txt" "$W/cen.c.$v.txt" | tail -1
done
