#!/usr/bin/env bash
# r10rgg12repro/reours12.sh — re-read ONLY OUR side of an already-built grid
# with a second binary.  The GOLDEN side of a grid is IMMUTABLE (same Surelog,
# same sources) and is never rebuilt, so a patched score can never be compared
# against a different golden.
#
#   usage: reours12.sh <griddir> <binary> <outdir-of-base-run> <outdir-new>
set -u
GD=${1:?griddir}
BIN=${2:?binary}
OLD=${3:?old outdir}
NEW=${4:?new outdir}
CEN=/tmp/r10rgg12_rcensus
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
mkdir -p "$NEW" || exit 1
cp "$OLD/golden.cen" "$NEW/golden.cen" || exit 1
: > "$NEW/ours.cen"
ok=0; nodb=0; noslang=0
for d in "$GD"/*/; do
  c=$(basename "$d")
  ( cd "$d" && "$BIN" top.sv --single-unit -o ours_pat.uhdm > slang_pat.log 2>&1; echo $? > slang_pat.rc )
  rc=$(cat "$d/slang_pat.rc" 2>/dev/null || echo 99)
  if [ ! -f "$d/golden.uhdm" ] || [ ! -f "$d/ours_pat.uhdm" ]; then
    echo "NODB $c slangrc=$rc"; nodb=$((nodb+1)); continue
  fi
  [ "$rc" != 0 ] && { echo "NOSLANG $c rc=$rc"; noslang=$((noslang+1)); }
  "$CEN" "$d/ours_pat.uhdm" 2>/dev/null | sed "s#^#$c\t#" >> "$NEW/ours.cen"
  ok=$((ok+1))
done
echo "-- cells-censused=$ok NODB=$nodb NOSLANG=$noslang -> $NEW"
