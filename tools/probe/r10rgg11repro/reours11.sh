#!/usr/bin/env bash
# r10rgg11/reours11.sh — re-read only OUR side of an already-compiled grid with
# a different binary.  The GOLDEN side of a grid is IMMUTABLE (same Surelog,
# same sources), so re-running it would only burn time; the .gold census files
# are COPIED so the scorer sees a complete pair set and can still report
# MISSING.
#   usage: reours11.sh <griddir> <slang binary> <old outdir> <new outdir>
set -u
G=${1:?griddir}; BIN=${2:?bin}; OLD=${3:?old outdir}; NEW=${4:?new outdir}
CEN=/tmp/r10rgg11_pcensus
[ -x "$BIN" ] || { echo "FATAL: no $BIN"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
mkdir -p "$NEW"; : > "$NEW/status.txt"
ok=0; noslang=0; nogold=0
for d in "$G"/*/; do
  n=$(basename "$d")
  if [ ! -f "$OLD/$n.gold" ]; then echo "$n NOGOLD" >> "$NEW/status.txt"; nogold=$((nogold+1)); continue; fi
  cp "$OLD/$n.gold" "$NEW/$n.gold"
  ( cd "$d" && "$BIN" top.sv -o "$d/slang_pat.uhdm" >"$d/sgp.log" 2>&1 </dev/null )
  rc=$?
  if [ ! -f "$d/slang_pat.uhdm" ]; then echo "$n NOSLANG rc=$rc" >> "$NEW/status.txt"; noslang=$((noslang+1)); continue; fi
  "$CEN" "$d/slang_pat.uhdm" > "$NEW/$n.ours" 2>/dev/null
  echo "$n OK rc=$rc" >> "$NEW/status.txt"; ok=$((ok+1))
done
echo "-- cells=$(wc -l < "$NEW/status.txt") OK=$ok NOSLANG=$noslang NOGOLD=$nogold"
