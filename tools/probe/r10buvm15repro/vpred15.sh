#!/usr/bin/env bash
# vbuvm15 VERIFIER predictor — read PRISTINE BYTES ONLY, before any patched
# sweep is consulted.  For every database in a verify_golden workdir it runs the
# DEEP census (whole argument subtree) on BOTH sides and prints the COLLAPSED
# call rows whose ref/actual list disagrees.
# GUARDS: the golden path comes from each dir's OWN cmds.txt; a dir missing
# either side is NAMED and COUNTED, never skipped silently.
set -u
WD=${1:?workdir}; P=${2:?out prefix}
CEN=${CEN:-/tmp/vbuvm15_cen2}
[ -x "$CEN" ] || { echo "FATAL no $CEN"; exit 3; }
: > "$P.golden"; : > "$P.ours"; n=0; miss=0
for d in "$WD"/*/*/; do
  [ -f "$d/cmds.txt" ] || continue
  mode=$(basename "$(dirname "$d")"); test=$(basename "$d")
  O=$d/slang.uhdm
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo "MISSING $mode/$test"; miss=$((miss+1)); continue; fi
  "$CEN" "$G" "$mode/$test" >> "$P.golden"
  "$CEN" "$O" "$mode/$test" >> "$P.ours"
  n=$((n+1))
done
echo "DEEPCENSUS dirs=$n MISSING=$miss -> $P.golden $P.ours"
