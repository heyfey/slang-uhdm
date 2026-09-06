#!/usr/bin/env bash
# r10uvm175 — the LAW'S FACE, counted over a whole `verify_golden` workdir, on
# BOTH sides.  MEASUREMENT ONLY; LHS is ALWAYS golden.
#
#   CEN=<ct175cen> wface175.sh <workdir> [<label>]
#
# Prints one line per row and an aggregate.  The golden path is read out of the
# row's OWN cmds.txt; a row missing either side prints SKIP and is COUNTED.
set -u
WD=${1:?workdir}
LBL=${2:-}
CEN=${CEN:-/tmp/r10uvm175_bin/ct175cen}
gw=0; gs=0; gb=0; gp=0; gt=0
ow=0; os=0; ob=0; op=0; ot=0
rows=0; skip=0
for d in "$WD"/*/*/; do
  O=$d/slang.uhdm; C=$d/cmds.txt; G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then skip=$((skip+1)); continue; fi
  rows=$((rows+1))
  gl=$("$CEN" "$G" --wface); ol=$("$CEN" "$O" --wface)
  num() { printf '%s' "$1" | sed -n "s/.*$2=\\([0-9]*\\).*/\\1/p"; }
  ga=$(num "$gl" withpaths); gth=$(num "$gl" this_super)
  gsu=$(num "$gl" SUBSCRIPTED-REFOBJ); gbi=$(num "$gl" BITSEL); gpl=$(num "$gl" PLAIN)
  oa=$(num "$ol" withpaths); oth=$(num "$ol" this_super)
  osu=$(num "$ol" SUBSCRIPTED-REFOBJ); obi=$(num "$ol" BITSEL); opl=$(num "$ol" PLAIN)
  gw=$((gw+ga)); gt=$((gt+gth)); gs=$((gs+gsu)); gb=$((gb+gbi)); gp=$((gp+gpl))
  ow=$((ow+oa)); ot=$((ot+oth)); os=$((os+osu)); ob=$((ob+obi)); op=$((op+opl))
  [ "$gsu$gbi" = "$osu$obi" ] || echo "FACEDIFF ${d#$WD/} G(sub=$gsu bit=$gbi) O(sub=$osu bit=$obi)"
done
echo "-- WFACE $LBL rows=$rows SKIP=$skip"
echo "   GOLDEN withpaths=$gw this_super=$gt SUBSCRIPTED-REFOBJ=$gs BITSEL=$gb PLAIN=$gp"
echo "   OURS   withpaths=$ow this_super=$ot SUBSCRIPTED-REFOBJ=$os BITSEL=$ob PLAIN=$op"
