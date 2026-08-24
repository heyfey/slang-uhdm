#!/usr/bin/env bash
# r10earl83 — THE CORPUS-WIDE WRITTEN-CAST CENSUS DRIVER.  MEASUREMENT ONLY.
#
# For every database in a verify_golden workdir: take the UNION of the two
# databases' own vpiCastOp SPANS, then ask BOTH databases what object each of
# those spans holds.  Golden's REDUCED casts are constants and can only be
# found this way; a census that looked for operations alone would be blind to
# exactly the population this pass is about (earl66's lesson, from the other
# side).
#
# It READS databases and DISPATCHES NOTHING — no test, fenced or otherwise, is
# ever run by this script.  The golden path comes from each test's OWN
# cmds.txt, so the census cannot silently read the wrong golden.
#
#   usage: cen83.sh <workdir> <outdir>
#   env:   CEN83 (path to ct83cen)
set -u
WD=${1:?workdir}; OUT=${2:?outdir}
CEN=${CEN83:?set CEN83}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$OUT"
n=0; nog=0
: > "$OUT/INDEX.txt"
for d in "$WD"/*/*/; do
  [ -f "$d/slang.uhdm" ] || continue
  [ -f "$d/cmds.txt" ]   || continue
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then nog=$((nog+1)); continue; fi
  rel=${d#"$WD"/}; rel=${rel%/}; tag=${rel//\//__}
  "$CEN" "$d/slang.uhdm" --spans 2>/dev/null >  "$OUT/$tag.spanO"
  "$CEN" "$G"            --spans 2>/dev/null >  "$OUT/$tag.spanG"
  sort -u "$OUT/$tag.spanO" "$OUT/$tag.spanG" > "$OUT/$tag.span"
  if [ ! -s "$OUT/$tag.span" ]; then
    rm -f "$OUT/$tag.span" "$OUT/$tag.spanO" "$OUT/$tag.spanG"; continue
  fi
  "$CEN" "$d/slang.uhdm" --at "$OUT/$tag.span" 2>/dev/null > "$OUT/$tag.ours"
  "$CEN" "$G"            --at "$OUT/$tag.span" 2>/dev/null > "$OUT/$tag.gold"
  echo "$tag" >> "$OUT/INDEX.txt"
  n=$((n+1))
done
echo "-- databases censused=$n  no-golden=$nog"
