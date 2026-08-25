#!/usr/bin/env bash
# Golden-check ONE moved boundary file: NEW_WRONG / LOST_RIGHT against Surelog.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
PRIS=${PRIS:?set PRIS}; PAT=${PATCHED:?set PATCHED}
ROOT=${PROBE_ROOT:?set PROBE_ROOT (a tools/probe-bearing tree)}
REL="$1"; SAFE=$(echo "$REL" | tr '/' '_')
D=${SCRATCH:-/tmp/r10v136_bg}/$SAFE; mkdir -p "$D"
SRCDIR=$(dirname "$ROOT/$REL"); B=$(basename "$REL")
cp "$SRCDIR"/*.sv "$SRCDIR"/*.svh "$SRCDIR"/*.v "$D"/ 2>/dev/null
for view in def elab; do
  EF=""; SF=""; [ "$view" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$D" && "$SL" -parse $SF -nobuiltin -nocache -sv "$B" >sl_$view.log 2>&1 </dev/null ); rcs=$?
  G=""
  for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && { cp "$D/$c/surelog.uhdm" "$D/g_$view.uhdm"; G=1; }; done
  ( cd "$D" && "$PRIS" "$B" --nobuiltin $EF -o o_$view.uhdm >/dev/null 2>&1 </dev/null )
  ( cd "$D" && "$PAT"  "$B" --nobuiltin $EF -o q_$view.uhdm >/dev/null 2>&1 </dev/null )
  if [ -z "$G" ] || [ ! -f "$D/o_$view.uhdm" ] || [ ! -f "$D/q_$view.uhdm" ]; then
    echo -e "$REL\t$view\tNO-GOLDEN(rc=$rcs)"; continue; fi
  for t in g o q; do bash "$(dirname "${BASH_SOURCE[0]}")/v136_norm.sh" "$D/${t}_$view.uhdm" > "$D/${t}_$view.norm"; done
  NW=$(comm -23 <(comm -23 "$D/q_$view.norm" "$D/g_$view.norm") "$D/o_$view.norm" | grep -c .; true)
  LR=$(comm -23 <(comm -12 "$D/g_$view.norm" "$D/o_$view.norm") "$D/q_$view.norm" | grep -c .; true)
  FX=$(comm -23 <(comm -12 "$D/g_$view.norm" "$D/q_$view.norm") "$D/o_$view.norm" | grep -c .; true)
  echo -e "$REL\t$view\tNEW_WRONG=$NW\tLOST_RIGHT=$LR\tNEWLY_AGREEING=$FX"
done
