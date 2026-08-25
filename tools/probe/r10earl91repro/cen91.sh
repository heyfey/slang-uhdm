#!/usr/bin/env bash
# r10earl91 — THE CORPUS-WIDE ASSIGNMENT-PATTERN OPERAND CENSUS DRIVER.  MEASUREMENT ONLY.
#
# For every database in a verify_golden workdir, run ct91pat on BOTH sides.
# ct91pat enumerates PATTERN OPERANDS by POSITION, so a bound that FOLDED on one side
# and stayed a reference on the other is still found under the SAME key — a
# census keyed on the object that changes would be blind to exactly this
# pass's population (earl66's lesson, from the other side).
#
# It READS databases and DISPATCHES NOTHING — no test, fenced or otherwise, is
# ever run by this script.  The golden path comes from each test's OWN
# cmds.txt, so the census cannot silently read the wrong golden.
#
#   usage: cen91.sh <workdir> <outdir> [ct91pat extra args...]
#   env:   CEN91 (path to ct91pat)
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
CEN=${CEN91:?set CEN91}
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
  "$CEN" "$d/slang.uhdm" "$@" 2>/dev/null > "$OUT/$tag.ours"
  "$CEN" "$G"            "$@" 2>/dev/null > "$OUT/$tag.gold"
  if [ ! -s "$OUT/$tag.ours" ] && [ ! -s "$OUT/$tag.gold" ]; then
    rm -f "$OUT/$tag.ours" "$OUT/$tag.gold"; continue
  fi
  echo "$tag" >> "$OUT/INDEX.txt"
  n=$((n+1))
done
echo "-- databases censused=$n  no-golden=$nog"
