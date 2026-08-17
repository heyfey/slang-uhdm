#!/usr/bin/env bash
# r10rgg3/score.sh — per-cell AGREEMENT score of each slang-uhdm binary against
# real Surelog, over every measured range line of every cell.
#
#   usage: BASE=<bin> PAT=<bin> ./score.sh <celldir> ...
#
# GUARDS: a cell whose GOLDEN side measured NOTHING is reported NO-GOLDEN and
# counted as a problem — a cell that measured nothing must never score as
# agreement; and a binary that produced no database scores 0 with NO-DATABASE.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
here=$(cd "$(dirname "$0")" && pwd)
bad=0; bt=0; bg=0; pt=0; pg=0
printf "%-28s %-6s %-12s %-12s\n" CELL LINES BASE PAT
for d in "$@"; do
  c=$(basename "$d")
  ( cd "$d" && "$SL" -parse -nopython -d uhdm -top top dut.sv > gold.dump 2> gold.err )
  python3 "$here/ranges.py" "$d/gold.dump" > "$d/gold.rng" 2>/dev/null
  n=$(wc -l < "$d/gold.rng")
  if [ "$n" -eq 0 ]; then printf "%-28s %-6s %s\n" "$c" 0 NO-GOLDEN; bad=$((bad+1)); continue; fi
  row=$(printf "%-28s %-6s" "$c" "$n")
  for tag in BASE PAT; do
    b=${!tag:-}
    if [ -z "$b" ]; then row="$row$(printf ' %-12s' -)"; continue; fi
    ( cd "$d" && "$b" --single-unit --top top dut.sv -o ours_$tag.uhdm > ours_$tag.log 2>&1 )
    if [ ! -f "$d/ours_$tag.uhdm" ]; then
      row="$row$(printf ' %-12s' NO-DATABASE)"; bad=$((bad+1)); continue
    fi
    "$DUMP" "$d/ours_$tag.uhdm" > "$d/ours_$tag.dump" 2>&1
    python3 "$here/ranges.py" "$d/ours_$tag.dump" > "$d/ours_$tag.rng" 2>/dev/null
    m=$(comm -12 <(sort "$d/gold.rng") <(sort "$d/ours_$tag.rng") | wc -l)
    row="$row$(printf ' %-12s' "$m/$n")"
    if [ "$tag" = BASE ]; then bt=$((bt+n)); bg=$((bg+m)); else pt=$((pt+n)); pg=$((pg+m)); fi
  done
  echo "$row"
done
echo "TOTAL BASE=$bg/$bt  PAT=$pg/$pt  PROBLEMS=$bad"
