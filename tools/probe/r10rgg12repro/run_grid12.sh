#!/usr/bin/env bash
# r10rgg12repro/run_grid12.sh — build BOTH databases for every cell of a grid
# and census them with rcensus12.
#
#   usage: run_grid12.sh <griddir> <binary> <outdir> [gold|nogold]
#
# GUARDS (each an ops trap this campaign has paid for):
#  * `nogold` reuses an already-built golden side (it is IMMUTABLE) so a patched
#    re-read never re-runs Surelog and can never silently compare against a
#    different golden;
#  * a cell whose EITHER side is missing prints NODB and is COUNTED — a driver
#    that reaches nothing must never read as perfection;
#  * slang's rc is recorded per cell (rc=139 segfaults must not read as a
#    normal "no database").
set -u
GD=${1:?griddir}
BIN=${2:?binary}
OUT=${3:?outdir}
MODE=${4:-gold}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10rgg12_rcensus
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
mkdir -p "$OUT" || exit 1
ok=0; nodb=0; noslang=0
for d in "$GD"/*/; do
  c=$(basename "$d")
  ( cd "$d" && rm -rf slpp_all
    if [ "$MODE" = gold ] && [ ! -f golden.uhdm ]; then
      "$SL" -parse -mt 0 -mp 0 top.sv > sl.log 2>&1
      [ -f slpp_all/surelog.uhdm ] && cp slpp_all/surelog.uhdm golden.uhdm
    fi
    "$BIN" top.sv --single-unit -o ours.uhdm > slang.log 2>&1
    echo "$?" > slang.rc )
  rc=$(cat "$d/slang.rc" 2>/dev/null || echo 99)
  if [ ! -f "$d/golden.uhdm" ] || [ ! -f "$d/ours.uhdm" ]; then
    echo "NODB $c slangrc=$rc"; nodb=$((nodb+1)); continue
  fi
  [ "$rc" != 0 ] && { echo "NOSLANG $c rc=$rc"; noslang=$((noslang+1)); }
  "$CEN" "$d/golden.uhdm" 2>/dev/null | sed "s#^#$c\t#" >> "$OUT/golden.cen"
  "$CEN" "$d/ours.uhdm"   2>/dev/null | sed "s#^#$c\t#" >> "$OUT/ours.cen"
  ok=$((ok+1))
done
echo "-- cells-censused=$ok NODB=$nodb NOSLANG=$noslang -> $OUT"
