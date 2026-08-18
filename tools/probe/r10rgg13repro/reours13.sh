#!/usr/bin/env bash
# r10rgg13repro/reours13.sh — re-read ONLY OUR side of an already-built grid.
# The golden side of a grid is IMMUTABLE; re-running Surelog for a patched
# re-read is how a pass silently compares against a different golden.
#   usage: reours13.sh <griddir> <binary> <outdir-of-the-base-run> <outdir-new>
set -u
GD=${1:?griddir}; BIN=${2:?binary}; OLD=${3:?baseout}; NEW=${4:?newout}
CEN=/tmp/r10rgg13_acensus
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
[ -x "$BIN" ] || { echo "FATAL: no $BIN"; exit 3; }
mkdir -p "$NEW" || exit 1
cp "$OLD/golden.cen" "$NEW/golden.cen"
: > "$NEW/ours.cen"
ok=0; nodb=0; noslang=0
for d in "$GD"/*/; do
  c=$(basename "$d")
  ( cd "$d" && "$BIN" top.sv --single-unit -o ourspat.uhdm > slangpat.log 2>&1
    echo "$?" > slangpat.rc; rm -rf slpp_all )
  rc=$(cat "$d/slangpat.rc" 2>/dev/null || echo 99)
  if [ ! -f "$d/golden.uhdm" ] || [ ! -f "$d/ourspat.uhdm" ]; then
    echo "NODB $c slangrc=$rc"; nodb=$((nodb+1)); continue
  fi
  [ "$rc" != 0 ] && { echo "NOSLANG $c rc=$rc"; noslang=$((noslang+1)); }
  "$CEN" "$d/ourspat.uhdm" 2>/dev/null | sed "s#^#$c\t#" >> "$NEW/ours.cen"
  ok=$((ok+1))
done
echo "-- cells-reread=$ok NODB=$nodb NOSLANG=$noslang -> $NEW"
