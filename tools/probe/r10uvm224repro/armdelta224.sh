#!/bin/bash
# § ifaceDefNetTypespecIsTheModuleRule224 — THE ARM DELTA GATE.
#   usage: armdelta224.sh <grid-outdir-PRISTINE> <grid-outdir-PATCHED>
# Both dirs must have been produced by grid224.sh from the SAME arm set; the
# golden dump is read from the PRISTINE dir and asserted identical to the
# patched dir's (golden cannot move when only our binary changed).
set -u
P=${1:?pristine grid outdir}; T=${2:?patched grid outdir}
H=$(cd "$(dirname "$0")" && pwd)
to=0; away=0; still=0; arms=0
for d in "$P"/*/; do
  n=$(basename "$d")
  gd="$P/$n/golden.dump"; gd2="$T/$n/golden.dump"
  pd="$P/$n/ours.dump";   td="$T/$n/ours.dump"
  for f in "$gd" "$gd2" "$pd" "$td"; do
    [ -f "$f" ] || { echo "ARM $n MISSING $f"; exit 4; }
  done
  # The dump's FIRST line embeds the database path, which differs between the
  # two grid outdirs; everything below it is the model and must be identical.
  cmp -s <(tail -n +2 "$gd") <(tail -n +2 "$gd2") || { echo "FATAL: golden moved for arm $n"; exit 4; }
  out=$(python3 "$H/cells224.py" "$gd" "$pd" "$td" "ARM $n ")
  echo "$out"
  r=$(echo "$out" | sed -n 's/.*TO-GOLDEN=\([0-9]*\) AWAY=\([0-9]*\) STILL-WRONG=\([0-9]*\).*/\1 \2 \3/p' | head -1)
  set -- $r
  to=$((to+$1)); away=$((away+$2)); still=$((still+$3)); arms=$((arms+1))
done
echo "-- ARMS=$arms  TO-GOLDEN=$to  AWAY=$away  STILL-WRONG=$still"
[ "$away" -eq 0 ] || { echo "FAIL: $away cell(s) moved AWAY from golden"; exit 5; }
echo "PASS: no cell moved away from golden"
