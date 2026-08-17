#!/usr/bin/env bash
# r10rgg3/run_grid.sh — GOLDEN (real Surelog) and one/two slang-uhdm binaries on
# every grid cell, side by side, one line per measured range.
#
#   usage: [BASE=<bin>] [PAT=<bin>] ./run_grid.sh <celldir> ...
#
# GUARD: a cell whose GOLDEN side produced no range at all prints NO-GOLDEN and
# is COUNTED; a run that measured nothing must never read as agreement.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
here=$(cd "$(dirname "$0")" && pwd)
bad=0
for d in "$@"; do
  c=$(basename "$d")
  ( cd "$d" && "$SL" -parse -nopython -d uhdm -top top dut.sv > gold.dump 2> gold.err )
  python3 "$here/ranges.py" "$d/gold.dump" > "$d/gold.rng" 2>/dev/null
  n=$(wc -l < "$d/gold.rng")
  [ "$n" -eq 0 ] && { echo "$c NO-GOLDEN"; bad=$((bad+1)); }
  echo "== $c"
  sed 's/^/  G /' "$d/gold.rng"
  for tag in BASE PAT; do
    b=${!tag:-}
    [ -z "$b" ] && continue
    ( cd "$d" && "$b" --single-unit --top top dut.sv -o ours_$tag.uhdm > ours_$tag.log 2>&1 )
    if [ -f "$d/ours_$tag.uhdm" ]; then
      "$DUMP" "$d/ours_$tag.uhdm" > "$d/ours_$tag.dump" 2>&1
      python3 "$here/ranges.py" "$d/ours_$tag.dump" 2>/dev/null | sed "s/^/  $tag /"
    else
      echo "  $tag NO-DATABASE"; bad=$((bad+1))
    fi
  done
done
echo "PROBLEMS=$bad"
