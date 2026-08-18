#!/usr/bin/env bash
# r10rgg10/reours10.sh — re-read the OURS side of an already-compiled grid with
# a different slang-uhdm binary.  The GOLDEN side of a grid is IMMUTABLE (same
# Surelog, same sources), so scoring a patch does not need Surelog again; this
# keeps the scoring loop to one binary run per cell.
#
#   usage: reours10.sh <griddir> <slang binary> <outdir> <suffix>
set -u
G=${1:?griddir}; BIN=${2:?bin}; O=${3:?outdir}; SFX=${4:?suffix}
CEN=/tmp/r10rgg10_pcensus
[ -x "$BIN" ] || { echo "FATAL: no $BIN"; exit 3; }
n=0; bad=0
for d in "$G"/*/; do
  c=$(basename "$d")
  [ -f "$d/top.sv" ] || continue
  ( cd "$d" && "$BIN" top.sv -o "$d/slang_$SFX.uhdm" >"$d/sg_$SFX.log" 2>&1 </dev/null )
  if [ -f "$d/slang_$SFX.uhdm" ]; then
    "$CEN" "$d/slang_$SFX.uhdm" > "$O/$c.$SFX" 2>/dev/null
  else
    echo "NOSLANG $c"; bad=$((bad+1))
  fi
  n=$((n+1))
done
echo "-- cells=$n NOSLANG=$bad"
