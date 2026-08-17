#!/usr/bin/env bash
# r10rgg4/run_grid.sh — GOLDEN (real Surelog) + up to two slang-uhdm binaries
# on every grid cell, side by side, one line per measured range bound.
#
#   usage: [BASE=<bin>] [PAT=<bin>] [PAT2=<bin>] ./run_grid.sh <celldir> ...
#
# GUARD: a cell whose GOLDEN side produced NO range line prints NO-GOLDEN and is
# COUNTED; a run that measured nothing must never read as agreement.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
here=$(cd "$(dirname "$0")" && pwd)
bad=0
for d in "$@"; do
  d=${d%/}; [ -d "$here/$d" ] && d=$here/$d
  c=$(basename "$d")
  ( cd "$d" && "$SL" -parse -nopython -d uhdm -top top dut.sv > gold.dump 2> gold.err )
  python3 "$here/attrib.py" "$d/gold.dump" > "$d/gold.rng" 2>/dev/null
  n=$(wc -l < "$d/gold.rng")
  echo "== $c"
  [ "$n" -eq 0 ] && { echo "  NO-GOLDEN"; bad=$((bad+1)); }
  sed 's/^/  G   /' "$d/gold.rng"
  for tag in BASE PAT PAT2; do
    b=${!tag:-}
    [ -z "$b" ] && continue
    ( cd "$d" && "$b" --single-unit --top top dut.sv -o ours_$tag.uhdm > ours_$tag.log 2>&1 )
    if [ -f "$d/ours_$tag.uhdm" ]; then
      "$DUMP" "$d/ours_$tag.uhdm" > "$d/ours_$tag.dump" 2>&1
      python3 "$here/attrib.py" "$d/ours_$tag.dump" 2>/dev/null | sed "s/^/  $tag /"
    else
      echo "  $tag NO-DATABASE"; bad=$((bad+1))
    fi
  done
done
echo "PROBLEMS=$bad"
